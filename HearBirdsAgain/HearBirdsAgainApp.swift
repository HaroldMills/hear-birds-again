//
//  HearBirdsAgainApp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//

import SwiftUI

@main
struct HearBirdsAgainApp: App {
    
    @StateObject var audioProcessor = AudioProcessor()
    
    var body: some Scene {
        WindowGroup {
            ContentView(audioProcessor: audioProcessor)
        }
    }
    
}
