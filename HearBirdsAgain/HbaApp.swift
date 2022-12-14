//
//  HbaApp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import SwiftUI
import AVFoundation


// TODO: Could we reduce latency via AVAudioSession.setPreferredIOBufferDuration?
// TODO: Look at AVAudioSession.inputLatency and AVAudioSession.outputLatency for different devices.


/*
 
 An audio session has a *current route*.
 A route has an array of *input ports* (usually just one) and an array of *output ports* (usually just one).
 A port has an optional array of *data sources* that can be switched between. If there is only one data source for a port, i.e. if there is no choice of data source, the optional array is nil.

 Audio session types:
 AVAudioSession - an audio *session*.
 AVAudioSessionRouteDescription - describes the input and output *ports* associated with a session.
 AVAudioSessionPortDescription - describes an input or output port.
 AVAudioSessionDataSourceDescription - describes a *data source* for an input or output port.
 
 */


private enum _Error: Error {
    case error(message: String)
}


@main
class HbaApp: App {
    
    
    @AppStorage("helpButtonsVisible") static var helpButtonsVisible = true
    @AppStorage("donateButtonVisible") static var donateButtonVisible = true
    @AppStorage("zeroHzCutoffVisible") static var zeroHzCutoffVisible = false
    @AppStorage("consoleTabVisible") static var consoleTabVisible = false
    
    
    var body: some Scene {
        
        WindowGroup {
            
            // Processor state save and load is modeled after code from the iOS
            // Scrumdinger app tutorial.
            HbaView(audioProcessor: audioProcessor, console: console, errors: errors) {
                audioProcessor.state.save() { result in
                    if case .failure(let error) = result {
                        errors.handleNonfatalError(message: "Audio processor state save failed. \(error.localizedDescription)")
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .onAppear {
                AudioProcessorState.load { result in
                    switch result {
                    case .failure(let error):
                        errors.handleNonfatalError(message: "Audio processor state load failed. \(error.localizedDescription)")
                    case .success(let state):
                        audioProcessor.state = state
                    }
                }
            }
            
        }
        
    }
    
    
    required init() {
        
        registerSongFinderAudioUnit()
        
        assert(songFinderAudioUnitPresent())
        
        do {
            try configureAudioSession()
        } catch _Error.error(let message) {
            errors.handleFatalError(message: "Audio session configuration failed. \(message)")
        } catch {
            errors.handleFatalError(message: "Audio session configuration failed. \(error.localizedDescription)")
        }

        setUpNotifications()
        
    }
    

    private func setUpNotifications() {
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self, selector: #selector(handleAudioSessionRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        
        notificationCenter.addObserver(
            self, selector: #selector(handleAudioSessionInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        
        notificationCenter.addObserver(
            self, selector: #selector(handleDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(handleUserDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)

    }


    @objc private func handleAudioSessionRouteChange(notification: Notification) {
        
        //  See https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_route_changes
        //   for documentation regarding handling audio session route changes.
        
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                  return
        }

        console.log()
        let reasonString = getAudioSessionRouteChangeReasonString(reason: reason)
        console.log("HbaApp.handleRouteChange: \(reasonString)")
        showAudioSessionCurrentRoute()
        
        do {
            try adjustNumberOfInputChannelsIfNeeded()
        } catch _Error.error(let message) {
            errors.handleNonfatalError(message: "adjustNumberOfInputChannelsIfNeeded failed. \(message)")
        } catch {
            errors.handleNonfatalError(message: "adjustNumberOfInputChannelsIfNeeded failed. \(error.localizedDescription)")
        }

        audioProcessor.handleAudioSessionRouteChange()

        switch reason {
            
        case .categoryChange:
            // audio session category changed
            
            if (AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint) {
                console.log("HbaApp.handleRouteChange: Secondary audio should be silenced.")
                audioProcessor.stop()
            } else {
                audioProcessor.restartIfRunning()
            }
            
        case .newDeviceAvailable:
            // route changed to use a new device, e.g. because headphones
            // were connected
            
            // Restart audio processor to use new device.
            audioProcessor.restartIfRunning()
            
        case .oldDeviceUnavailable:
            // route changed because device it was using became unavailable,
            // e.g. because headphones were disconnected
            
            // Always stop processing in this case. Apple's documentation
            // for handling audio session route changes (see link above)
            // recommends pausing playback when headphones are disconnected,
            // and shows how to test if the previous route's output was to
            // headphones. However, we have found that the suggested test
            // does not always succeed, for example if headphones are
            // connected via a device like the RODE AI-Micro. So we stop
            // processing (and hence playback) in all cases.
            audioProcessor.stop()
            
        default:
            // route changed for some other reason
            
            // Always update state and restart processing in this case.
            // We have received .override and .routeConfigurationChange
            // reasons after plugging in Apple wired earbuds when
            // processing is running, and the following seems to be
            // needed in one or both of those cases.
            
            audioProcessor.restartIfRunning()
            
        }
        
    }

    
    // See note in `setUpNotifications` method above.
    @objc private func handleAudioSessionInterruption(notification: Notification) {

        // See https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_interruptions
        // for an example of how to respond to audio session interruptions,
        // including how to distinguish the beginnings of interruptions
        // from the ends, and how to read the `.shouldResume` interruption
        // option.

        // Get interruption type.
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
            
        case .began:
            
            // print("HbaApp.handleAudioSessionInterruption began")
            
            console.log()
            console.log("HbaApp.handleAudioSessionInterruption began")

            // Stop audio processor if it's running. If we don't do this, we receive an
            // audio session route change notification that triggers a processor restart.
            // The processor start fails since it can't activate the HBA audio session,
            // and the user sees an ugly nonfatal error alert.
            //
            // For some reason, stopping the audio processor causes one or more messages
            // like the following to appear on the Xcode console:
            //
            // 2022-11-22 13:00:20.267854-0500 HearBirdsAgain[26302:2248049] [aurioc]
            //     AURemoteIO.cpp:1128  failed: 561017449 (enable 3, outf< 1 ch,  48000 Hz, Float32> inf< 1 ch,  48000 Hz, Float32>)
            audioProcessor.stop()
            
        case .ended:
            
            // print("HbaApp.handleAudioSessionInterruption ended")
            
            console.log()
            console.log("HbaApp.handleAudioSessionInterruption ended")

        default:
            
            // print("HbaApp.handleAudioSessionInterruption other")
            
            console.log()
            console.log("HbaApp.handleAudioSessionInterruption other")

        }
        
    }
    
    
    @objc private func handleDeviceOrientationChange(notification: Notification) {
        // console.log("Device orientation changed to \(UIDevice.current.orientation.rawValue).")
        let session = AVAudioSession.sharedInstance()
        if let source = session.inputDataSource {
            if source.dataSourceName == "Back" {
                if let pattern = source.selectedPolarPattern {
                    if pattern == .stereo {
                        setPreferredInputOrientation()
                    }
                }
            }
        }
    }
    
    
    @objc private func handleUserDefaultsDidChange(notification: Notification) {
        
        // If zero hertz cutoff is disabled, set cutoff to default
        // instead of zero.
        if !HbaApp.zeroHzCutoffVisible && audioProcessor.cutoff == 0 {
            audioProcessor.cutoff = AudioProcessor.defaultState.cutoff
        }
        
    }
    
    
}


private func registerSongFinderAudioUnit() {
    AUAudioUnit.registerSubclass(
        SongFinderAudioUnit.self,
        as: SongFinderAudioUnit.componentDescription,
        name: "HBAx: SongFinder",
        version: 0)
}


private func songFinderAudioUnitPresent() -> Bool {
    let components = AVAudioUnitComponentManager.shared().components(
        matching: SongFinderAudioUnit.componentDescription)
    return (components.count == 1 && components[0].name == "SongFinder")
}


private func configureAudioSession() throws {
    
    // showAudioSessionAvailableCategories()
    
    let session = AVAudioSession.sharedInstance()
    
    // Set session category.
    do {
        
        // Do *not* include `mode: .measurement` here. That disables built-in stereo iPhone input.
        
        // Do *not* include the `.allowBluetooth` option here. As of November, 2022 that makes it
        // impossible to use built-in stereo iPhone input with Bluetooth output for Apple's AirPods
        // and AirPods Pro. If we specify `.allowBluetooth`, the audio session offers us to use
        // only mono AirPod input paired with mono AirPod output or iPhone input paired with iPhone
        // output, but not built-in stereo iPhone input paired with stereo AirPod output.
        //
        // The Apple AirPods (3rd generation) and AirPods Pro (2nd generation) support only 24 kHz
        // mono input, which for our purposes is not preferable to the 48 kHz built-in stereo iPhone
        // input. Perhaps a future AirPods model or Bluetooth earbuds from a different manufacturer
        // will support 48 kHz stereo input.
        
        try session.setCategory(.playAndRecord, options: [.allowBluetoothA2DP, .allowAirPlay])
        
    } catch {
        throw _Error.error(message: "Could not set audio session category. \(String(describing: error))")
    }
    
    // Set preferred sample rate.
    let sampleRate = AudioProcessor.requiredSampleRate
    do {
        try session.setPreferredSampleRate(sampleRate)
    } catch {
        throw _Error.error(message: "Could not set audio session preferred sample rate. \(String(describing: error))")
    }
    
    // Set preferred I/O buffer duration.
    let ioBufferDuration = 128.0 / sampleRate
    do {
        try session.setPreferredIOBufferDuration(ioBufferDuration)
    } catch {
        throw _Error.error(message: "Could not set audio session preferred I/O buffer duration. \(String(describing: error))")
    }
    
}


private func showAudioSessionAvailableCategories() {
    
    let session = AVAudioSession.sharedInstance()
    let categories = session.availableCategories

    console.log("")
    console.log("Audio session categories:")
    for category in categories {
        console.log("\(category)")
    }
    
}


// This seems to be necessary since `reason.rawValue` is an integer instead of
// the string we return here, and `RouteChangeReason` doesn't seem to provide
// something like this function.
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
    showAudioSessionSampleRate(session: session)
    showAudioSessionInputGain(session: session)
    showAudioSessionInputPorts(ports: route.inputs, name: "Current audio route")
    // showAudioSessionInputPorts(ports: session.availableInputs!, name: "Available audio session")
    showAudioSessionOutputPorts(ports: route.outputs, name: "Current audio session")
    // showAudioSessionOutputDataSources(sources: session.outputDataSources!, name: "Available audio session")

}


private func showAudioSessionSampleRate(session: AVAudioSession) {
    console.log("")
    console.log("Sample rate: \(session.sampleRate)")
}


private func showAudioSessionInputGain(session: AVAudioSession) {
    console.log("")
    console.log("Input gain: \(session.inputGain)")
    console.log("isInputGainSettable: \(session.isInputGainSettable)")
}


private func showAudioSessionInputPorts(ports: [AVAudioSessionPortDescription], name: String) {
    
    console.log("")
    console.log("\(name) input port(s):")
    
    for port in ports {
        
        let channelCountText = getChannelCountText(port: port)
        console.log("    \(port.portName) (\(channelCountText))")
        
        if let source = port.selectedDataSource {
            console.log("        selected data source:")
            console.log("            \(source.dataSourceName)")
            if let pattern = source.selectedPolarPattern {
                console.log("                \(pattern.rawValue)")
            } else {
                console.log("                no selected polar pattern")
            }
        } else {
            console.log("        no selected data source")
        }
        
        if let sources = port.dataSources {
            if sources.count == 0 {
                console.log("        no available data sources")
            } else {
                console.log("        available data sources:")
                for source in sources {
                    console.log("            \(source.dataSourceName)")
                    if let patterns = source.supportedPolarPatterns {
                        for pattern in patterns {
                            console.log("                \(pattern.rawValue)")
                        }
                    } else {
                        console.log("                source has no supported polar patterns")
                    }
                }
            }
        } else {
            console.log("        no available data sources")
        }
        
    }

}


private func getChannelCountText(port: AVAudioSessionPortDescription) -> String {
    
    if let channels = port.channels {
        
        switch channels.count {
            
        case 1:
            return "mono"
            
        case 2:
            return "stereo"
            
        default:
            return "\(channels.count) channels"
            
        }
        
    } else {
        return "channel count unavailable"
    }
        
}


private func showAudioSessionOutputPorts(ports: [AVAudioSessionPortDescription], name: String) {
    
    console.log("")
    console.log("\(name) output port(s):")
    
    for port in ports {
        let channelCountText = getChannelCountText(port: port)
        console.log("    \(port.portName) (\(channelCountText))")
    }

}


private func showAudioSessionOutputDataSources(sources: [AVAudioSessionDataSourceDescription], name: String) {
    
    console.log("")
    console.log("\(name) output data source(s):")
    
    for source in sources {
        console.log("    \(source.dataSourceName)")
    }
    
}


private func adjustNumberOfInputChannelsIfNeeded() throws {
    
    let session = AVAudioSession.sharedInstance()
    
    console.log()
    console.log("HbaApp.adjustNumberOfInputChannelsIfNeeded:")
    console.log("    inputs: \(session.inputNumberOfChannels) (max \(session.maximumInputNumberOfChannels))")
    console.log("    outputs \(session.outputNumberOfChannels) (max \(session.maximumOutputNumberOfChannels))")
    
    if session.inputNumberOfChannels == 2 && session.outputNumberOfChannels == 1 && isAudioInputBuiltInMic() {
        // input is stereo from built-in mic but output is mono
        
        // Switch to mono input from built-in mic.
        
        guard let availableInputs = session.availableInputs,
              let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
            console.log("Could not find built-in mic input.")
            return
        }
        
        guard let dataSources = builtInMicInput.dataSources,
              let bottomDataSource = dataSources.first(where: { $0.dataSourceName == "Bottom" }) else {
            console.log("Could not find built-in mic bottom data source.")
            return
        }

        do {
            try bottomDataSource.setPreferredPolarPattern(.omnidirectional)
        } catch {
            console.log("Could not set built-in mic bottom data source to omnidirectional polar pattern.")
            return
        }
        
        do {
            try builtInMicInput.setPreferredDataSource(bottomDataSource)
        } catch {
            console.log("Could not set built-in mic preferred data source to bottom.")
            return
        }
        
        do {
            try session.setPreferredInput(builtInMicInput)
        } catch {
            console.log("Could not set preferred input to built-in mic.")
            return
        }
        
    } else if session.inputNumberOfChannels == 1 && session.outputNumberOfChannels == 2 {
        // input is mono but output is stereo

        if session.maximumInputNumberOfChannels == 2 {
            // current input supports stereo
            
            // Indicate that we would prefer stereo input.
            
            do {
                try session.setPreferredInputNumberOfChannels(2)
            } catch {
                console.log("Could not set preferred number of input channels to two. Error message was: \(error.localizedDescription)")
            }

        } else {
            // current input does not support stereo
            
            // Uncomment the following to test mono input from Apple EarPods on an iPhone.
            // return
            
            // Switch to stereo input from built-in mic if available.
            
            guard let availableInputs = session.availableInputs,
                  let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
                console.log("Could not find built-in mic input.")
                return
            }
            
            guard let dataSources = builtInMicInput.dataSources,
                  let backDataSource = dataSources.first(where: { $0.dataSourceName == "Back" }) else {
                console.log("Could not find built-in mic back data source.")
                return
            }

            guard let supportedPolarPatterns = backDataSource.supportedPolarPatterns else {
                console.log("Could not get built-in mic back data source supported polar patterns.")
                return
            }

            if supportedPolarPatterns.contains(.stereo) {
                
                console.log("Seting preferred input to built-in mic back stereo...")
                
                do {
                    try backDataSource.setPreferredPolarPattern(.stereo)
                } catch {
                    console.log("Could not set built-in mic back data source to stereo polar pattern.")
                    return
                }
                
                do {
                    try builtInMicInput.setPreferredDataSource(backDataSource)
                } catch {
                    console.log("Could not set built-in mic preferred data source to back.")
                    return
                }
                
                do {
                    try session.setPreferredInput(builtInMicInput)
                } catch {
                    console.log("Could not set preferred input to built-in mic.")
                    return
                }
                
                setPreferredInputOrientation()
                
            } else {

                console.log("Built-in mic back data source does not support stereo polar pattern.")
                
            }
            
        }
        
    }
    
}


private func isAudioInputBuiltInMic() -> Bool {
    let session = AVAudioSession.sharedInstance()
    let inputs = session.currentRoute.inputs
    return inputs.first(where: { $0.portType == .builtInMic }) != nil
}


private func setPreferredInputOrientation() {
    if let orientation = getPreferredInputOrientation() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setPreferredInputOrientation(orientation)
            // console.log("Set preferred input orientation to \(orientation.rawValue).")
        } catch {
            // console.log("Could not set audio session preferred input orientation.")
        }
    }
}


private func getPreferredInputOrientation() -> AVAudioSession.StereoOrientation? {
    
    switch UIDevice.current.orientation {
        
    case .portrait:
        return .portrait
        
    case .portraitUpsideDown:
        return .portraitUpsideDown
        
    // Note that it's not a mistake that for UIDeviceOrientation.landscapeLeft we
    // return AVAudioSession.StereoOrientation.landscapeRight. Apple defines the
    // two in such a way that this is correct. See
    // https://developer.apple.com/documentation/uikit/uideviceorientation and
    // https://developer.apple.com/documentation/avfaudio/avaudiosession/stereoorientation
    case .landscapeLeft:
        return .landscapeRight
        
    // Note that it's not a mistake that for UIDeviceOrientation.landscapeRight we
    // return AVAudioSession.StereoOrientation.landscapeLeft. Apple defines the
    // two in such a way that this is correct. See
    // https://developer.apple.com/documentation/uikit/uideviceorientation and
    // https://developer.apple.com/documentation/avfaudio/avaudiosession/stereoorientation
    case .landscapeRight:
        return .landscapeLeft
        
    default:
        return Optional.none
        
    }
    
}


//private func getCurrentAudioInput() -> AVAudioSessionDataSourceDescription? {
//    let session = AVAudioSession.sharedInstance()
//    return session.inputDataSource
//}
//
//
//private func getAvailableAudioInputs() throws -> [AVAudioSessionPortDescription] {
//    
//    let session = AVAudioSession.sharedInstance()
//    
//    guard let inputs = session.availableInputs else {
//        throw _Error.error(message: "Could not get available audio session inputs.")
//    }
//    
//    return inputs
//    
//}
