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


struct Gains: Codable {
    var inputGain: Float? = nil
    var appGain: AUValue = 0
}


typealias InputPortGains = Dictionary<String, Gains>


struct AudioProcessorState: Codable {
    
    
    var cutoff = 0
    var pitchShift = 2
    var windowType = WindowType.Hann
    var windowSize = 20
    var inputPortGains: InputPortGains = [:]
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
private let defaultInputGain: AUValue = 100         // percent
private let defaultAppGain: AUValue = 0           // dB
private let stoppedOutputLevel: AUValue = -200      // dB


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
    
    // This class doesn't use the value of this property, but instead uses the
    // `getInputPortName` method whenever it needs to get the input port name.
    // This property is an observable version of the input port name for use
    // by a SwiftUI user interface. The property is updated by the audio
    // processor via its `updateInputInfo` method whenever the its state is
    // set or the audio session route changes.
    @Published var inputName = ""
    
    // This class doesn't use the value of this property, but instead relies
    // on AVAudioSession.sharedInstance().isInputGainSettable. This property
    // more or less creates an observable version of that property for use by
    // a SwiftUI user interface. This property is updated from outside of this
    // class in response to audio session route changes.
    // TODO: Update this property from within this class.
    @Published var isInputGainSettable = false
    
    @Published var inputGain: AUValue = defaultInputGain {
        
        didSet {
            
            // Set gain in audio session.
            let session = AVAudioSession.sharedInstance()
            if session.isInputGainSettable {
                do {
                    try session.setInputGain(inputGain / 100)
                } catch {
                    errors.handleNonfatalError(message: "Could not set input gain. \(error.localizedDescription)")
                    return
                }
            }
            
            // Update `inputPortGains`.
            if let portName = getInputPortName() {
                inputPortGains[portName] = Gains(inputGain: inputGain, appGain: appGain)
            }
            
        }
        
    }
    
    private func getInputPortName() -> String? {
        let inputs = AVAudioSession.sharedInstance().currentRoute.inputs
        if inputs.count > 0 {
            return inputs[0].portName
        } else {
            return nil
        }
    }
    
    @Published var appGain: AUValue = defaultAppGain {
        
        didSet {
            
            // Set gain in SongFinder audio unit.
            // Note that unlike for some other SongFinder parameters
            // we do not need to restart here here since the SongFinder
            // audio unit can respond to changes in the value of this
            // parameter while running.
            songFinderAudioUnit.parameters.gain.value = appGain
            
            // Update `inputPortGains`.
            if let portName = getInputPortName() {
                let gainSettable = AVAudioSession.sharedInstance().isInputGainSettable
                let inputGainOptional = gainSettable ? inputGain : nil
                inputPortGains[portName] = Gains(inputGain: inputGainOptional, appGain: appGain)
            }
            
        }

    }
    
    private var inputPortGains: InputPortGains = [:]
    
    @Published var balance: AUValue = defaultProcessorState.balance {
        didSet {
            // Note that unlike for some other SongFinder parameters
            // we do not need to restart here here since the SongFinder
            // audio unit can respond to changes in the value of this
            // parameter while running.
            songFinderAudioUnit.parameters.balance.value = balance
        }
    }
    
    @Published var outputLevels: [AUValue] = [stoppedOutputLevel]
    
    var isOutputMono: Bool {
        return outputLevels.count == 1
    }
    
    private var levelUpdateTimer: Timer?
    
    var state: AudioProcessorState {
        
        get {
            return AudioProcessorState(
                cutoff: cutoff, pitchShift: pitchShift,
                windowType: windowType, windowSize: windowSize,
                inputPortGains: inputPortGains, balance: balance)
        }
        
        set {
            cutoff = newValue.cutoff
            pitchShift = newValue.pitchShift
            windowType = newValue.windowType
            windowSize = newValue.windowSize
            inputPortGains = newValue.inputPortGains
            balance = newValue.balance
            updateInputInfo()
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
            
            reinitializeOutputLevelsIfNeeded()
            
            do {
                try engine.start()
            } catch {
                errors.handleNonfatalError(message: "Attempt to start audio engine threw error: \(String(describing: error)).")
                return
            }
            
            levelUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                let parameters = self.songFinderAudioUnit.parameters
                self.outputLevels[0] = parameters.outputLevel0.value
                if !self.isOutputMono {
                    self.outputLevels[1] = parameters.outputLevel1.value
                }
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
            gain: appGain,
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
    
    
    func handleAudioSessionRouteChange() {
        console.log()
        console.log("AudioProcessor.handleAudioSessionRouteChange")
        updateInputInfo()
        reinitializeOutputLevelsIfNeeded()
    }
    
    
    private func updateInputInfo() {
        if let portName = getInputPortName() {
            inputName = portName
            if let gains = inputPortGains[portName] {
                if let gain = gains.inputGain {
                    inputGain = gain
                }
                appGain = gains.appGain
            }
        }
    }
    
    
    private func reinitializeOutputLevelsIfNeeded() {
        
        let channelCount = engine.outputNode.outputFormat(forBus: 0).channelCount
        
        if channelCount != outputLevels.count {
            // number of output channels has changed
            
            outputLevels = Array(repeating: stoppedOutputLevel, count: Int(channelCount))
            
        }
        
    }
    
    
    func stop() {
        
        // handleFatalError(message: "Could not stop audio engine.")
        
        if (running) {
            
            console.log()
            console.log("AudioProcessor stopping")
            
            engine.stop()
            deconfigureAudioEngine()
            
            // Stop output level updates.
            levelUpdateTimer?.invalidate()
            
            // Set output levels to `stoppedOutputLevel`.
            outputLevels = Array(repeating: stoppedOutputLevel, count: outputLevels.count)
            
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
