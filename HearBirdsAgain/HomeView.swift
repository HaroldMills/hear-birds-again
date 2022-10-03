//
//  HomeView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    @State private var helpButtonsVisible = false
    @State private var pitchShiftHelpVisible = false
    @State private var startFrequencyHelpVisible = false
    @State private var outputLevelHelpVisible = false
    @State private var audioVolumeHelpVisible = false
    
    private var helpButtonTitle: String {
        get {
            return helpButtonsVisible ? "Hide Help" : "Show Help"
        }
    }

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
                
                if helpButtonsVisible {
                    
                    Button {
                        pitchShiftHelpVisible = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    
                }
                
            }
            .padding()

            VStack {
                
                HStack {
                    
                    Text("Start Frequency (kHz):")
                    
                    if helpButtonsVisible {
                        
                        Button {
                            startFrequencyHelpVisible = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        
                    }
                    
                }
                
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
                
                HStack {
                    
                    Text("Output Level:")
                    
                    if helpButtonsVisible {
                        
                        Button {
                            outputLevelHelpVisible = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        
                    }

                }
                
                LevelMeters(audioProcessor: audioProcessor)
                
            }
            .padding()

            VStack {
                
                HStack {
                    
                    Text("iOS Audio Volume:")
                    
                    if helpButtonsVisible {
                        
                        Button {
                            audioVolumeHelpVisible = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        
                    }
                    
                }
                
                VolumeView()
                    .frame(width: 250, height: 15)
                
            }
            .padding()
            
            HStack {
                
                RunButton(audioProcessor: audioProcessor)
                    .padding()
                
                Button(helpButtonTitle) {
                    helpButtonsVisible = !helpButtonsVisible
                }
                
            }
            
            
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
