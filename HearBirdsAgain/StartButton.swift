//
//  StartButton.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/5/22.
//


import SwiftUI

struct StartButton: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    
    private var buttonTitle: String {
        get {
            return audioProcessor.running ? "Stop" : "Start"
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

struct StartButton_Previews: PreviewProvider {
    static var previews: some View {
        StartButton(audioProcessor: audioProcessor)
    }
}
