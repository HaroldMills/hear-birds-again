//
//  AudioProcessor.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation
import AVFoundation


// TODO: Check that input sample rate is 48 kHz and quit if not.


enum WindowType: AUValue, CustomStringConvertible {
    
    case Hann = 0.0
    case SongFinder = 1.0
    
    var description: String {
        switch self {
            case .Hann: return "Hann"
            case .SongFinder: return "SongFinder"
        }
    }
    
}


class AudioProcessor: ObservableObject {
    
    
    @Published var running = false
    
    @Published var cutoff = 0 {
        didSet {
            setAudioUnitParam(key: "cutoff", value: AUValue(cutoff))
            restartIfRunning()
        }
    }
    
    @Published var pitchShift = 2 {
        didSet {
            setAudioUnitParam(key: "pitchShift", value: AUValue(pitchShift))
            restartIfRunning()
        }
    }
    
    @Published var windowType = WindowType.Hann {
        didSet {
            setAudioUnitParam(key: "windowType", value: AUValue(windowType.rawValue))
            restartIfRunning()
        }
    }
    
    @Published var windowSize = 20 {
        didSet {
            setAudioUnitParam(key: "windowSize", value: AUValue(windowSize))
            restartIfRunning()
        }
    }
    
    @Published var gain: AUValue = 0 {
        didSet {
            // Note that unlike for all of the other SongFinder parameters
            // we do not need to restart here here since the SongFinder
            // audio unit can respond to changes in the value of this
            // parameter while running.
            setAudioUnitParam(key: "gain", value: AUValue(gain))
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
