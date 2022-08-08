//
//  HbaApp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//

import SwiftUI
import AVFoundation


// TODO: Handle audio session interruptions.


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
        
        // showAudioSessionAvailableCategories()
        
        do {
            
            try setAudioSessionCategory()
            
            try configureAudioSession()
            
        } catch _Error.error(let message) {
            errors.handleFatalError(message: "Audio processor initialization failed. \(message)")
        } catch {
            errors.handleFatalError(message: "Audio processor initialization failed. \(error.localizedDescription)")
        }

        setUpNotifications()
        
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

        console.log()
        let reasonString = getAudioSessionRouteChangeReasonString(reason: reason)
        console.log("HeadBirdsAgainApp.handleRouteChange: \(reasonString)")
        showAudioSessionCurrentRoute()

        switch reason {
            
        case .categoryChange:
            // audio session category changed
            
            updateIsInputGainSettable()
            
            if (AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint) {
                console.log("HearBirdsAgainApp.handleRouteChange: Secondary audio should be silenced.")
                audioProcessor.stop()
            } else {
                audioProcessor.restartIfRunning()
            }
            
        case .newDeviceAvailable:
            // route changed to use a new device, e.g. because headphones
            // were connected
            
            // Restart audio processor to use new device.
            updateIsInputGainSettable()
            audioProcessor.restartIfRunning()
            
        case .oldDeviceUnavailable:
            // route changed because device it was using became unavailable,
            // e.g. because headphones were disconnected
            
            updateIsInputGainSettable()
            
            // Always stop processing in this case. Apple's documentation
            // for handling audio session route changes (see link above)
            // recommends pausing playback when headphones are disconnected,
            // and shows how to test if the previous route's output was to
            // headphones. However, we have found that the suggested test
            // does not always succeed, for example if headphones are
            // connected via a device like the R0DE AI-Micro. So we stop
            // processing (and hence playback) in all cases.
            audioProcessor.stop()
            
        default: ()
            
        }
        
    }


}


private func updateIsInputGainSettable() {
    let session = AVAudioSession.sharedInstance()
    audioProcessor.isInputGainSettable = session.isInputGainSettable
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


private func setAudioSessionCategory() throws {
    
    let session = AVAudioSession.sharedInstance()

    do {
        
        // Do *not* include `mode: .measurement` here. That disables stereo input.
        try session.setCategory(.playAndRecord)
        
        try session.setActive(true)
        
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


// For some reason, the information retrieved by `showAudioSessionPorts` for
// the ports of `AVAudioSession.sharedInstance().availableInputs` does not
// include stereo polar patterns, while that retrieved for
// `AVAudioSession.sharedInstance().currentRoute.inputs` does (in particular,
// for my iPhone SE model A2275 and iOS 15.5). So we rely on the latter
// rather than the former for information about audio input capabilities.
private func showAudioSessionCurrentRoute() {
    let session = AVAudioSession.sharedInstance()
    let route = session.currentRoute
    showAudioSessionInputGain(session: session)
    showAudioSessionInputPorts(ports: route.inputs)
    showAudioSessionOutputPorts(ports: route.outputs)
}


private func showAudioSessionInputGain(session: AVAudioSession) {
    
    console.log("")
    console.log("Input gain: \(session.inputGain)")
    console.log("isInputGainSettable: \(session.isInputGainSettable)")

//    if gainSettable && gain != 1 {
//        do {
//            try session.setInputGain(1)
//        } catch {
//            errors.handleNonfatalError(message: "Could not set input gain. \(error.localizedDescription)")
//        }
//    }
    
}


private func showAudioSessionInputPorts(ports: [AVAudioSessionPortDescription]) {
    
    console.log("")
    console.log("Current audio input port(s):")
    
    for port in ports {
        
        var channelCountText = "could not get channel count"
        if let channels = port.channels {
            channelCountText = getChannelCountText(channelCount: channels.count)
        }
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


private func showAudioSessionOutputPorts(ports: [AVAudioSessionPortDescription]) {
    
    console.log("")
    console.log("Current audio output port(s):")
    
    for port in ports {
        
        var channelCountText = "could not get channel count"
        if let channels = port.channels {
            channelCountText = getChannelCountText(channelCount: channels.count)
        }
        console.log("    \(port.portName) (\(channelCountText))")
        
    }

}
