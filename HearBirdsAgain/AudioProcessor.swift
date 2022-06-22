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
        }
    }
    
    @Published var pitchShift = 2 {
        didSet {
            setAudioUnitParam(key: "pitchShift", value: AUValue(pitchShift))
        }
    }
    
    @Published var windowType = WindowType.Hann {
        didSet {
            setAudioUnitParam(key: "windowType", value: AUValue(windowType.rawValue))
        }
    }
    
    @Published var windowSize = 20 {
        didSet {
            setAudioUnitParam(key: "windowSize", value: AUValue(windowSize))
        }
    }
    
    @Published var gain: AUValue = 0 {
        didSet {
            getAudioUnitParam(key: "gain").value = gain;
            // setAudioUnitParam(key: "gain", value: AUValue(gain))
        }
    }
    
    private let engine = AVAudioEngine()
    
    private let songFinder = AVAudioUnitEffect(audioComponentDescription: SongFinderAudioUnit.componentDescription)

    
    init() {
        configureAudioEngine()
        initializeState()
        showInputSampleRate()
    }

    
    private func configureAudioEngine() {
        
        let input = engine.inputNode
        let output = engine.outputNode
        let format = input.inputFormat(forBus: 0)
        
        engine.attach(songFinder)
        
        engine.connect(input, to: songFinder, format: format)
        engine.connect(songFinder, to: output, format: format)

    }
    
    
    private func initializeState() {
        
        self.cutoff = Int(getAudioUnitParam(key: "cutoff").value)
        
        self.pitchShift = Int(getAudioUnitParam(key: "pitchShift").value)
        
        let windowTypeParam = getAudioUnitParam(key: "windowType")
        self.windowType = WindowType(rawValue: windowTypeParam.value) ?? WindowType.Hann
        
        self.windowSize = Int(getAudioUnitParam(key: "windowSize").value)
        
        self.gain = getAudioUnitParam(key: "gain").value
        
    }
    
    
    private func getAudioUnitParam(key: String) -> AUParameter {
        
        // We force unwrap the parameter tree and the parameter in this
        // method since we know by design that a SongFinder audio unit
        // has a parameter tree, and we assume that the parameter tree
        // includes a parameter for the specified key.
        
        let parameterTree = songFinder.auAudioUnit.parameterTree!
        return parameterTree.value(forKey: key) as! AUParameter
        
    }
    
    
    private func setAudioUnitParam(key: String, value: AUValue) {
        getAudioUnitParam(key: key).value = value
        restartIfRunning()
    }
    
    
    private func showInputSampleRate() {
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        logger.log()
        logger.log("AudioProcessor.showInputSampleRate \(format.sampleRate)")
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
    
    
    func restartIfRunning() {
        if (running) {
            stop()
            start()
        }
    }
    
    
}


// The one and only AudioProcessor of this app.
let audioProcessor = AudioProcessor()
