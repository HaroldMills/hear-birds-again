//
//  HearBirdsAgainApp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//

import SwiftUI
import AVFoundation


@main
struct HearBirdsAgainApp: App {
    
    @StateObject var audioProcessor = AudioProcessor()

    var body: some Scene {
        WindowGroup {
            ContentView(audioProcessor: audioProcessor, logger: logger, errors: errors)
        }
    }
    
    init() {
        registerSongFinderAudioUnit()
        assert(songFinderAudioUnitPresent())
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
