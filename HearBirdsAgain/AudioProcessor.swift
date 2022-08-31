//
//  AudioProcessor.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation
import AVFoundation


// TODO: Check that input sample rate is 48 kHz and quit if not.


enum WindowType: AUValue, CustomStringConvertible, Codable {
    
    case Hann = 0.0
    case SongFinder = 1.0
    
    var description: String {
        switch self {
            case .Hann: return "Hann"
            case .SongFinder: return "SongFinder"
        }
    }
    
}


struct AudioProcessorState: Codable {
    
    
    var cutoff = 0
    var pitchShift = 2
    var windowType = WindowType.Hann
    var windowSize = 20
    var inputGain: Float = 0
    var digitalGain: AUValue = 0
    var balance: AUValue = 0
    
    
    // Modeled after code from the iOS Scrumdinger app tutorial.
    static func load(completion: @escaping (Result<AudioProcessorState, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try getSavedProcessorStateUrl()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(AudioProcessorState()))
                    }
                    return
                }
                let state = try JSONDecoder().decode(AudioProcessorState.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(state))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    
    // Modeled after code from the iOS Scrumdinger app tutorial.
    func save(completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let state = try JSONEncoder().encode(self)
                let fileUrl = try getSavedProcessorStateUrl()
                try state.write(to: fileUrl)
                DispatchQueue.main.async {
                    completion(.success(1))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    
}


private func getSavedProcessorStateUrl() throws -> URL {
    try FileManager.default.url(for: .documentDirectory,
                                   in: .userDomainMask,
                                   appropriateFor: nil,
                                   create: false)
        .appendingPathComponent("Processor.state")
}


private let defaultProcessorState = AudioProcessorState()
private let stoppedOutputLevel: AUValue = -200      // dB
private let maxSongFinderGain: AUValue = 20         // dB


class AudioProcessor: ObservableObject {
    
    
    // Note that this class is the source of truth for the audio
    // processing parameters (i.e. cutoff, pitchShift, etc.) of
    // this app. The values of these parameters should be changed
    // only via the published properties of this class, from which
    // the changes will flow to other parts of the app, e.g. the
    // pitch shifting audio unit.
    
    
    @Published var running = false
    
    @Published var cutoff = defaultProcessorState.cutoff {
        didSet {
            songFinderAudioUnit.parameters.cutoff.value = AUValue(cutoff)
            restartIfRunning()
        }
    }
    
    @Published var pitchShift = defaultProcessorState.pitchShift {
        didSet {
            songFinderAudioUnit.parameters.pitchShift.value = AUValue(pitchShift)
            restartIfRunning()
        }
    }
    
    @Published var windowType = defaultProcessorState.windowType {
        didSet {
            songFinderAudioUnit.parameters.windowType.value = AUValue(windowType.rawValue)
            restartIfRunning()
        }
    }
    
    @Published var windowSize = defaultProcessorState.windowSize {
        didSet {
            songFinderAudioUnit.parameters.windowSize.value = AUValue(windowSize)
            restartIfRunning()
        }
    }
    
    // This class doesn't use the value of this property, but instead relies
    // on AVAudioSession.sharedInstance().isInputGainSettable. This property
    // more or less creates an observable version of that property for use by
    // a SwiftUI user interface. This property is updated from outside of this
    // class in response to audio session route changes
    @Published var isInputGainSettable = false
    
    @Published var inputGain: AUValue = defaultProcessorState.inputGain {
        didSet {
            let session = AVAudioSession.sharedInstance()
            if session.isInputGainSettable {
                do {
                    try session.setInputGain(inputGain / 100)
                } catch {
                    errors.handleNonfatalError(message: "Could not set input gain. \(error.localizedDescription)")
                    return
                }
                songFinderAudioUnit.parameters.gain.value = 0
            }
        }
    }
    
    @Published var digitalGain: AUValue = defaultProcessorState.digitalGain {
        didSet {
            let session = AVAudioSession.sharedInstance()
            if !session.isInputGainSettable {
                // Note that unlike for some other SongFinder parameters
                // we do not need to restart here here since the SongFinder
                // audio unit can respond to changes in the value of this
                // parameter while running.
                songFinderAudioUnit.parameters.gain.value = songFinderGain
            }
        }

    }
    
    @Published var balance: AUValue = defaultProcessorState.balance {
        didSet {
            // Note that unlike for some other SongFinder parameters
            // we do not need to restart here here since the SongFinder
            // audio unit can respond to changes in the value of this
            // parameter while running.
            songFinderAudioUnit.parameters.balance.value = AUValue(balance)
        }
    }
    
    @Published var outputLevel: AUValue = stoppedOutputLevel
    
    var songFinderGain: AUValue {
        let session = AVAudioSession.sharedInstance()
        return session.isInputGainSettable ? 0 : (digitalGain / 100) * maxSongFinderGain
    }
    
    var levelUpdateTimer: Timer?
    
    var state: AudioProcessorState {
        
        get {
            return AudioProcessorState(
                cutoff: cutoff, pitchShift: pitchShift,
                windowType: windowType, windowSize: windowSize,
                inputGain: inputGain, digitalGain: digitalGain,
                balance: balance)
        }
        
        set {
            cutoff = newValue.cutoff
            pitchShift = newValue.pitchShift
            windowType = newValue.windowType
            windowSize = newValue.windowSize
            inputGain = newValue.inputGain
            digitalGain = newValue.digitalGain
            balance = newValue.balance
        }
        
    }
    
    private let engine = AVAudioEngine()
    
    private let songFinderEffect = AVAudioUnitEffect(audioComponentDescription: SongFinderAudioUnit.componentDescription)
    
    private var songFinderAudioUnit: SongFinderAudioUnit {
        return songFinderEffect.auAudioUnit as! SongFinderAudioUnit
    }
    
    
    func start() {
        
        if !running {
            
            configureSongFinderAudioUnit()
            configureAudioEngine()
            
            do {
                try engine.start()
            } catch {
                errors.handleNonfatalError(message: "Attempt to start audio engine threw error: \(String(describing: error)).")
                return
            }
            
            levelUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                self.outputLevel = self.songFinderAudioUnit.parameters.outputLevel.value
            }
            
            running = true
            
        }
        
    }
    
    
    private func configureSongFinderAudioUnit() {
        
        songFinderAudioUnit.parameters.setValues(
            cutoff: AUValue(cutoff),
            pitchShift: AUValue(pitchShift),
            windowType: AUValue(windowType.rawValue),
            windowSize: AUValue(windowSize),
            gain: songFinderGain,
            balance: balance)
        
    }
    
    
    private func configureAudioEngine() {
        
        let input = engine.inputNode
        let inputFormat = input.inputFormat(forBus: 0)
        
        let output = engine.outputNode
        let outputFormat = output.outputFormat(forBus: 0)
        
        console.log()
        console.log("AudioProcessor starting with \(inputFormat.channelCount) input channels and \(outputFormat.channelCount) output channels")
        
        engine.attach(songFinderEffect)
        
        engine.connect(input, to: songFinderEffect, format: inputFormat)
        engine.connect(songFinderEffect, to: output, format: outputFormat)

    }
    
    
    func stop() {
        
        // handleFatalError(message: "Could not stop audio engine.")
        
        if (running) {
            
            console.log()
            console.log("AudioProcessor stopping")
            
            engine.stop()
            deconfigureAudioEngine()
            
            levelUpdateTimer?.invalidate()
            
            outputLevel = stoppedOutputLevel
            
            running = false
            
        }
        
    }
    
    
    private func deconfigureAudioEngine() {
        engine.detach(songFinderEffect)
    }
    
    
    func restartIfRunning() {
        if (running) {
            stop()
            start()
        }
    }
    
    
    private func showInputSampleRate() {
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        console.log()
        console.log("AudioProcessor.showInputSampleRate \(format.sampleRate)")
    }

    
}


// The one and only AudioProcessor of this app.
let audioProcessor = AudioProcessor()
