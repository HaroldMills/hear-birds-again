//
//  AudioProcessor.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import Foundation
import AVFoundation


// TODO: Consider moving audio session management to app class.

// TODO: Do we need to activate audio session?

// TODO: Handle audio session interruptions.

// TODO: Notify development team of errors, perhaps using something like Firebase Crashlytics.

// TODO: Check that input sample rate is 48 kHz and quit if not.


/*
 
 An audio session has a *current route*.
 A route has an array of *input ports* (usually just one) and an array of *output ports* (usually just one).
 A port may have an array of *data sources* that can be switched between. If there is only one data source for a port, i.e. if there is no choice of data source, the array is nil.

 Audio session types:
 AVAudioSession - an audio *session*.
 AVAudioSessionRouteDescription - describes the input and output *ports* associated with a session.
 AVAudioSessionPortDescription - describes an input or output port.
 AVAudioSessionDataSourceDescription - describes a *data source* for an input or output port.
 
 */


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
    private let songFinder: AVAudioUnitEffect

    
    init() {
        
        // We must create the SongFinder before calling any
        // instance methods, since Swift requires that all of
        // an object's stored properties be initialized before
        // any of its methods are called.
        songFinder = createSongFinder()

        showAudioSessionAvailableCategories()
        
        do {
            
            try setAudioSessionCategory()
            
            showAudioSessionAvailableInputPorts()

            try configureAudioSession()
            
        } catch _Error.error(let message) {
            handleFatalError(message: "Audio processor initialization failed. \(message)")
        } catch {
            handleFatalError(message: "Audio processor initialization failed. \(String(describing: error))")
        }

        setUpNotifications()
        
        configureAudioEngine()
        
        initializeState()

        showAudioSessionCurrentRoute()

        // showInputSampleRate()
        
    }

    
    private func setUpNotifications() {
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self, selector: #selector(handleAudioSessionRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)

    }


    @objc private func handleAudioSessionRouteChange(notification: Notification) {
        
        //  See https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_route_changes
        //   for documentation regarding handling audio session route changes.
        
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                  return
        }
    
        logger.log()
        let reasonString = getAudioSessionRouteChangeReasonString(reason: reason)
        logger.log("AudioProcessor.handleRouteChange: \(reasonString)")
        showAudioSessionCurrentRoute()
    
        switch reason {
            
        case .categoryChange:
            // audio session category changed
            
            if (AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint) {
                logger.log("AVAudioProcessor.handleRouteChange: Secondary audio should be silenced.")
                stop()
            }
            
        case .newDeviceAvailable:
            // route changed to use a new device, e.g. because headphones
            // were connected
            
            // I'm not sure quite why, but this seems to be necessary to ensure
            // that processing uses new input and/or output device.
            restartIfRunning()
            
        case .oldDeviceUnavailable:
            // route changed because device it was using became unavailable,
            // e.g. because headphones were disconnected
            
            // Always stop processing in this case. Apple's documentation
            // for handling audio session route changes (see link above)
            // recommends pausing playback when headphones are disconnected,
            // and shows how to test if the previous route's output was to
            // headphones. However, we have found that the suggested test
            // does not always succeed, for example if headphones are
            // connected via a device like the R0DE AI-Micro. So we stop
            // processing (and hence playback) in all cases.
            stop()
            
        default: ()
            
        }
        
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
        errors.nonfatalErrorMessage = message
        errors.nonfatalErrorOccurred = true
    }
    
    
    func handleFatalError(message: String) {
        errors.fatalErrorMessage = message
        errors.fatalErrorOccurred = true
    }
    
}


private func createSongFinder() -> AVAudioUnitEffect {
    return AVAudioUnitEffect(audioComponentDescription: SongFinderAudioUnit.componentDescription)
}


private func setAudioSessionCategory() throws {
    
    let session = AVAudioSession.sharedInstance()

    do {
        
        try session.setCategory(
            AVAudioSession.Category.playAndRecord,
            mode: AVAudioSession.Mode.measurement)
        
    } catch {
        throw _Error.error(message: "Could not set audio session category. \(String(describing: error))")
    }

}


private func getCurrentAudioInput() -> AVAudioSessionDataSourceDescription? {
    let session = AVAudioSession.sharedInstance()
    return session.inputDataSource
}


private func getAvailableAudioInputs() throws -> [AVAudioSessionPortDescription] {
    
    let session = AVAudioSession.sharedInstance()
    
    guard let inputs = session.availableInputs else {
        throw _Error.error(message: "Could not get available audio session inputs.")
    }
    
    return inputs
    
}


private func configureAudioSession() throws {
    
    let session = AVAudioSession.sharedInstance()
    
    // Configure audio session.
    do {
        
        let sampleRate = 48000.0;
        
        try session.setPreferredSampleRate(sampleRate)

        let ioBufferDuration = 128.0 / sampleRate
        try session.setPreferredIOBufferDuration(ioBufferDuration)
        
    } catch {
        throw _Error.error(message: "Could not configure audio session. \(String(describing: error))")
    }
    
}


private func showAudioSessionAvailableCategories() {
    
    let session = AVAudioSession.sharedInstance()
    let categories = session.availableCategories

    logger.log("")
    logger.log("Audio session categories:")
    for category in categories {
        logger.log("\(category)")
    }
    
}


private func showAudioSessionAvailableInputPorts() {
    
    let session = AVAudioSession.sharedInstance()
    
    if let ports = session.availableInputs {
        showAudioSessionPorts(ports: ports, title: "Available input ports")
    } else {
        logger.log("Could not get available input ports.")
    }
    
}


private func getAudioSessionRouteChangeReasonString(reason: AVAudioSession.RouteChangeReason) -> String {
    
    switch reason {
        
    case .unknown:
        return "unknown"
        
    case .newDeviceAvailable:
        return "newDeviceAvailable"
        
    case .oldDeviceUnavailable:
        return "oldDeviceUnavailable"
        
    case .categoryChange:
        return "categoryChange"
        
    case .override:
        return "override"
        
    case .wakeFromSleep:
        return "wakeFromSleep"
        
    case .noSuitableRouteForCategory:
        return "noSuitableRouteForCategory"
        
    case .routeConfigurationChange:
        return "routeConfigurationChange"
        
    default:
        return "unrecognized"
        
    }
    
}


private func showAudioSessionCurrentRoute() {
    let session = AVAudioSession.sharedInstance()
    let route = session.currentRoute
    showAudioSessionPorts(ports: route.inputs, title: "Current audio input ports")
    showAudioSessionPorts(ports: route.outputs, title: "Current audio output ports")
}


private func showAudioSessionPorts(ports: [AVAudioSessionPortDescription], title: String) {
    
    logger.log("")
    logger.log("\(title):")
    
    for port in ports {
        
        var channelCountText = "could not get channels"
        if let channels = port.channels {
            channelCountText = getChannelCountText(channelCount: channels.count)
        }
        logger.log("    \(port.portName) (\(channelCountText))")
        
        if let sources = port.dataSources {
            for source in sources {
                logger.log("        \(source.dataSourceName)")
            }
        }
        
    }

}


private func getChannelCountText(channelCount: Int) -> String {
    
    switch channelCount {
        
    case 1:
        return "mono"
        
    case 2:
        return "stereo"
        
    default:
        return "\(channelCount) channels"
        
    }
        
}
