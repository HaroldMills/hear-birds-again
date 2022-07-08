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
    var gain: AUValue = 0
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
private let stoppedOutputLevel: AUValue = -200


class AudioProcessor: ObservableObject {
    
    
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
    
    @Published var gain: AUValue = defaultProcessorState.gain {
        didSet {
            // Note that unlike for some other SongFinder parameters
            // we do not need to restart here here since the SongFinder
            // audio unit can respond to changes in the value of this
            // parameter while running.
            songFinderAudioUnit.parameters.gain.value = AUValue(gain)
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
    
    var levelUpdateTimer: Timer?
    
    var state: AudioProcessorState {
        
        get {
            return AudioProcessorState(
                cutoff: cutoff, pitchShift: pitchShift, windowType: windowType,
                windowSize: windowSize, gain: gain, balance: balance)
        }
        
        set {
            cutoff = newValue.cutoff
            pitchShift = newValue.pitchShift
            windowType = newValue.windowType
            windowSize = newValue.windowSize
            gain = newValue.gain
            balance = newValue.balance
        }
        
    }
    
    private let engine = AVAudioEngine()
    
    private let songFinderEffect = AVAudioUnitEffect(audioComponentDescription: SongFinderAudioUnit.componentDescription)
    
    private var songFinderAudioUnit: SongFinderAudioUnit {
        return songFinderEffect.auAudioUnit as! SongFinderAudioUnit
    }
    
    
    init() {
        configureAudioEngine()
        setSongFinderState()
        // showInputSampleRate()
    }
    
    
    private func configureAudioEngine() {
        
        let input = engine.inputNode
        let output = engine.outputNode
        let format = input.inputFormat(forBus: 0)
        
        engine.attach(songFinderEffect)
        
        engine.connect(input, to: songFinderEffect, format: format)
        engine.connect(songFinderEffect, to: output, format: format)

    }
    
    
    private func setSongFinderState() {
        
        songFinderAudioUnit.parameters.setValues(
            cutoff: AUValue(cutoff),
            pitchShift: AUValue(pitchShift),
            windowType: AUValue(windowType.rawValue),
            windowSize: AUValue(windowSize),
            gain: AUValue(gain),
            balance: AUValue(balance))
        
        restartIfRunning()
        
    }
    
    
    func restartIfRunning() {
        if (running) {
            stop()
            start()
        }
    }
    
    
    func start() {
        
        print("AudioProcessor.start")
        
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
    
    
    func stop() {
        print("AudioProcessor.stop")
        // handleFatalError(message: "Could not stop audio engine.")
        if (running) {
            engine.stop()
            levelUpdateTimer?.invalidate()
            outputLevel = stoppedOutputLevel
            running = false
        }
    }
    
    
    private func showInputSampleRate() {
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        logger.log()
        logger.log("AudioProcessor.showInputSampleRate \(format.sampleRate)")
    }

    
}


// The one and only AudioProcessor of this app.
let audioProcessor = AudioProcessor()
