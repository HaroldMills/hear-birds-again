//
//  HomeView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var audioProcessor: AudioProcessor

    @State private var pitchShiftHelpVisible = false
    @State private var startFrequencyHelpVisible = false
    @State private var outputLevelHelpVisible = false
    @State private var audioVolumeHelpVisible = false
    
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
                
                if HbaApp.helpButtonsVisible {
                    HelpButton { pitchShiftHelpVisible = true }
                }
                
            }
            .padding()

            VStack {
                
                HStack {
                    
                    Text("Start Frequency (kHz):")
                    
                    if HbaApp.helpButtonsVisible {
                        HelpButton { startFrequencyHelpVisible = true }
                    }
                    
                }
                
                Picker("Start Frequency", selection: $audioProcessor.cutoff) {
                    if HbaApp.zeroHzCutoffVisible {
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
                
                HStack {
                    
                    Text("Output Level:")
                    
                    if HbaApp.helpButtonsVisible {
                        HelpButton { outputLevelHelpVisible = true }
                    }
                    
                }
                
                LevelMeters(audioProcessor: audioProcessor)
                
            }
            .padding()

            VStack {
                
                HStack {
                    
                    Text("iOS Audio Volume:")
                    
                    if HbaApp.helpButtonsVisible {
                        HelpButton { audioVolumeHelpVisible = true }
                    }
                    
                }
                
                VolumeView()
                    .frame(width: 250, height: 15)
                
            }
            .padding()
            
            RunButton(audioProcessor: audioProcessor)
                .padding()
                
        }
        .hbaScrollbar()
        .hbaBackground()
        .sheet(isPresented: $pitchShiftHelpVisible) {
            PitchShiftHelp(isPresented: $pitchShiftHelpVisible)
        }
        .sheet(isPresented: $startFrequencyHelpVisible) {
            StartFrequencyHelp(isPresented: $startFrequencyHelpVisible)
        }
        .sheet(isPresented: $outputLevelHelpVisible) {
            OutputLevelHelp(isPresented: $outputLevelHelpVisible)
        }
        .sheet(isPresented: $audioVolumeHelpVisible) {
            AudioVolumeHelp(isPresented: $audioVolumeHelpVisible)
        }

    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(audioProcessor: audioProcessor)
    }
}
