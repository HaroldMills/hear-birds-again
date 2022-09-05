//
//  RunButton.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/5/22.
//


import SwiftUI

struct RunButton: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    
    private var buttonTitle: String {
        get {
            return audioProcessor.running ? "Stop" : "Run"
        }
    }
    
    var body: some View {
        
        Button(buttonTitle) {

            if (audioProcessor.running) {
                audioProcessor.stop()
            } else {
                audioProcessor.start()
            }

        }
        
    }
    
}

struct RunButton_Previews: PreviewProvider {
    static var previews: some View {
        RunButton(audioProcessor: audioProcessor)
    }
}
