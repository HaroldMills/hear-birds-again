//
//  HomeView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Title()
                .padding()
            
            HStack {
                
                Text("Pitch Shift:")
            
                Picker("Pitch Shift", selection: $audioProcessor.pitchShift) {
                    Text("1/2").tag(2)
                    Text("1/3").tag(3)
                    Text("1/4").tag(4)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                
            }
            .padding()

            VStack {
                
                Text("Start Frequency (kHz):")
            
                Picker("Start Frequency", selection: $audioProcessor.cutoff) {
                    Text("0").tag(0)
                    Text("2").tag(2000)
                    Text("2.5").tag(2500)
                    Text("3").tag(3000)
                    Text("4").tag(4000)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                
            }
            .padding()
            
            LevelMeters(audioProcessor: audioProcessor)
                .padding()

            RunButton(audioProcessor: audioProcessor)
                .padding()
            
            Spacer()
            
//                Text(
//                    "If you find this app useful, please [donate](https://hearbirdsagain.org/donate/) to support its continued development and maintenance.")
//
//                Spacer()
            
        }
        .hbaBackground()
        
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(audioProcessor: audioProcessor)
    }
}
