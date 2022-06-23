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


class AudioProcessor: ObservableObject {
    
    
    @Published var running = false
    
    @Published var cutoff = defaultProcessorState.cutoff {
        didSet {
            setAudioUnitParam(key: "cutoff", value: AUValue(cutoff))
            restartIfRunning()
        }
    }
    
    @Published var pitchShift = defaultProcessorState.pitchShift {
        didSet {
            setAudioUnitParam(key: "pitchShift", value: AUValue(pitchShift))
            restartIfRunning()
        }
    }
    
    @Published var windowType = defaultProcessorState.windowType {
        didSet {
            setAudioUnitParam(key: "windowType", value: AUValue(windowType.rawValue))
            restartIfRunning()
        }
    }
    
    @Published var windowSize = defaultProcessorState.windowSize {
        didSet {
            setAudioUnitParam(key: "windowSize", value: AUValue(windowSize))
            restartIfRunning()
        }
    }
    
    @Published var gain: AUValue = defaultProcessorState.gain {
        didSet {
            // Note that unlike for all of the other SongFinder parameters
            // we do not need to restart here here since the SongFinder
            // audio unit can respond to changes in the value of this
            // parameter while running.
            setAudioUnitParam(key: "gain", value: AUValue(gain))
        }
    }
    
    var state: AudioProcessorState {
        
        get {
            return AudioProcessorState(
                cutoff: cutoff, pitchShift: pitchShift, windowType: windowType,
                windowSize: windowSize, gain: gain)
        }
        
        set {
            cutoff = newValue.cutoff
            pitchShift = newValue.pitchShift
            windowType = newValue.windowType
            windowSize = newValue.windowSize
            gain = newValue.gain
        }
        
    }
    
    private let engine = AVAudioEngine()
    
    private let songFinder = AVAudioUnitEffect(audioComponentDescription: SongFinderAudioUnit.componentDescription)
    
    init() {
        configureAudioEngine()
        setSongFinderState()
        // showInputSampleRate()
    }
    
    
    private func configureAudioEngine() {
        
        let input = engine.inputNode
        let output = engine.outputNode
        let format = input.inputFormat(forBus: 0)
        
        engine.attach(songFinder)
        
        engine.connect(input, to: songFinder, format: format)
        engine.connect(songFinder, to: output, format: format)

    }
    
    
    private func setSongFinderState() {
        setAudioUnitParam(key: "cutoff", value: AUValue(cutoff))
        setAudioUnitParam(key: "pitchShift", value: AUValue(pitchShift))
        setAudioUnitParam(key: "windowType", value: AUValue(windowType.rawValue))
        setAudioUnitParam(key: "windowSize", value: AUValue(windowSize))
        setAudioUnitParam(key: "gain", value: AUValue(gain))
        restartIfRunning()
    }
    
    
    private func setAudioUnitParam(key: String, value: AUValue) {
        
        // We force unwrap the parameter tree and the parameter in this
        // method since we know by design that a SongFinder audio unit
        // has a parameter tree, and we assume that the parameter tree
        // includes a parameter for the specified key.
        let parameterTree = songFinder.auAudioUnit.parameterTree!
        let parameter = parameterTree.value(forKey: key) as! AUParameter
        
        parameter.value = value
        
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
        
        running = true
        
    }
    
    
    func stop() {
        print("AudioProcessor.stop")
        // handleFatalError(message: "Could not stop audio engine.")
        engine.stop()
        running = false
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
