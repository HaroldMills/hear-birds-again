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
            
            Title("Hear Birds Again")
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
                    if HbaApp.isZeroHzCutoffEnabled {
                        Text("0").tag(0)
                    }
                    Text("2").tag(2000)
                    Text("2.5").tag(2500)
                    Text("3").tag(3000)
                    Text("4").tag(4000)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                
            }
            .padding()
            
            VStack {
                Text("Output Level:")
                LevelMeters(audioProcessor: audioProcessor)
            }
            .padding()

            VStack {
                Text("iOS Audio Volume:")
                VolumeView()
                    .frame(width: 250, height: 15)
            }
            .padding()
            
            RunButton(audioProcessor: audioProcessor)
                .padding()
            
        }
        .hbaScrollbar()
        .hbaBackground()
                
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(audioProcessor: audioProcessor)
    }
}
