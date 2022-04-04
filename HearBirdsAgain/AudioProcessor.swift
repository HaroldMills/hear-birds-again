//
//  AudioProcessor.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation
import AVFoundation


// TODO: Notify development team of errors, perhaps using something like Firebase Crashlytics.

// TODO: Check that input sample rate is 48 kHz. Is it safe to assume that?


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


private enum _Error: Error {
    case error(message: String)
}


class AudioProcessor: ObservableObject {
    
    
    @Published var nonfatalErrorOccurred = false
    
    @Published var nonfatalErrorMessage = ""
    
    @Published var fatalErrorOccurred = false
    
    @Published var fatalErrorMessage = ""
    
    @Published var running = false
    
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
    
    @Published var windowSize: AUValue = 20 {
        didSet {
            setAudioUnitParam(key: "windowSize", value: windowSize)
        }
    }
    
    private let engine = AVAudioEngine()
    private let songFinder: AVAudioUnitEffect

    
    init() {
        
        registerSongFinderAudioUnit()
        
        assert(isSongFinderAudioUnitPresent())
        
        // We must create the SongFinder before calling any
        // instance methods, since Swift requires that all of
        // an object's stored properties be initialized before
        // any of its methods are called.
        songFinder = createSongFinder()

        // showAvailableAudioSessionCategories()
        
        do {
            
            try setAudioSessionCategory()
        
            // try showAvailableAudioInputs()

            try configureAudioSession()
            
        } catch _Error.error(let message) {
            handleFatalError(message: "Audio processor initialization failed. \(message)")
        } catch {
            handleFatalError(message: "Audio processor initialization failed. \(String(describing: error))")
        }

        configureAudioEngine()
        
        initializeState()

        // showAudioRoute()
        
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
    
    
    private func initializeState() {
        
        self.pitchShift = Int(getAudioUnitParam(key: "pitchShift").value)
        
        let windowTypeParam = getAudioUnitParam(key: "windowType")
        self.windowType = WindowType(rawValue: windowTypeParam.value) ?? WindowType.Hann
        
        self.windowSize = getAudioUnitParam(key: "windowSize").value
        
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
        print("Input sample rate: \(format.sampleRate)")
    }
    
    
    func start() {
        
        print("AudioProcessor.start")
        
        do {
            try engine.start()
            // throw _Error.error(message: "Something bad happened.")
        } catch {
            handleNonfatalError(message: "Attempt to start audio engine threw error: \(String(describing: error)).")
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
    
    
    func handleNonfatalError(message: String) {
        nonfatalErrorMessage = message
        nonfatalErrorOccurred = true
    }
    
    
    func handleFatalError(message: String) {
        fatalErrorMessage = message
        fatalErrorOccurred = true
    }
    
    
}


private func registerSongFinderAudioUnit() {
    AUAudioUnit.registerSubclass(
        SongFinderAudioUnit.self,
        as: SongFinderAudioUnit.componentDescription,
        name: "HBAx: SongFinder",
        version: 0)
}


private func isSongFinderAudioUnitPresent() -> Bool {
    let components = AVAudioUnitComponentManager.shared().components(
        matching: SongFinderAudioUnit.componentDescription)
    return (components.count == 1 && components[0].name == "SongFinder")
}


private func createSongFinder() -> AVAudioUnitEffect {
    return AVAudioUnitEffect(audioComponentDescription: SongFinderAudioUnit.componentDescription)
}


private func showAvailableAudioSessionCategories() {
    
    let session = AVAudioSession.sharedInstance()
    let categories = session.availableCategories

    print("Audio session categories:")
    for category in categories {
        print(category)
    }
    
}


private func setAudioSessionCategory() throws {
    
    let session = AVAudioSession.sharedInstance()

    do {
        try session.setCategory(AVAudioSession.Category.playAndRecord)
    } catch {
        throw _Error.error(message: "Could not set audio session category. \(String(describing: error))")
    }

}


private func showAvailableAudioInputs() throws {
    
    let inputs = try getAvailableAudioInputs()
    
    print("Available audio session inputs:")
    for input in inputs {
        print(input)
    }

}


private func getAvailableAudioInputs() throws -> [AVAudioSessionPortDescription] {
    
    let session = AVAudioSession.sharedInstance()
    
    guard let inputs = session.availableInputs else {
        throw _Error.error(message: "Could not get available audio session inputs.")
    }
    
    return inputs
    
}


private func configureAudioSession() throws {
    
    let inputs = try getAvailableAudioInputs()
    
    let session = AVAudioSession.sharedInstance()
    
    // Configure audio session.
    do {
        
        let sampleRate = 48000.0;
        
        try session.setPreferredSampleRate(sampleRate)

        let ioBufferDuration = 128.0 / sampleRate
        try session.setPreferredIOBufferDuration(ioBufferDuration)
        
        try session.setPreferredInput(inputs[inputs.count - 1])
        
    } catch {
        throw _Error.error(message: "Could not configure audio session. \(String(describing: error))")
    }
    
}


private func showAudioRoute() {
    let session = AVAudioSession.sharedInstance()
    let route = session.currentRoute
    print("Audio session inputs:")
    print("\(route.inputs)")
    print("Audio session outputs:")
    print("\(route.outputs)")
}
