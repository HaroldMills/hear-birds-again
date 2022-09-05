//
//  ControlsView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/5/22.
//

import SwiftUI

struct ControlsView: View {
    
    private let windowControlsVisible = false

    @ObservedObject var audioProcessor: AudioProcessor
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Title(subtitle: "Less-frequently Used Controls")
                .padding()
            
            if windowControlsVisible {
                
                HStack {
                    
                    Text("Window:")
                    
                    Picker("Window", selection: $audioProcessor.windowType) {
                        Text("Hann").tag(WindowType.Hann)
                        Text("SongFinder").tag(WindowType.SongFinder)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    
                }
                .padding()
                
                VStack {

                    Text("Window Size (ms):")
                    
                    Picker("Window Size", selection: $audioProcessor.windowSize) {
                        Text("5").tag(5)
                        Text("10").tag(10)
                        Text("15").tag(15)
                        Text("20").tag(20)
                        Text("25").tag(25)
                        Text("30").tag(30)
                        Text("35").tag(35)
                        Text("40").tag(40)
                        Text("45").tag(45)
                        Text("50").tag(50)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()

                }
                .padding()
                
            }

//            VStack {
//                HStack {
//                    Text("Gain:")
//                    Slider(value: $audioProcessor.gain, in: 0...24)
//                }
//                Text(String(format: "%.1f dB", audioProcessor.gain))
//            }
//            .padding()

            HStack {
                Spacer()
                VStack {
                    if audioProcessor.isInputGainSettable {
                        Stepper("Gain: \(audioProcessor.inputGain.formatted()) %", value: $audioProcessor.inputGain, in: 0...100, step: 5)
                    } else {
                        Stepper("Gain: \(audioProcessor.digitalGain.formatted()) %", value: $audioProcessor.digitalGain, in: 0...100, step: 5)
                    }
                }
                .fixedSize()
                Spacer()
            }
            .padding()

            HStack {
                Spacer()
                VStack {
                    Stepper("Balance: \(audioProcessor.balance.formatted()) dB", value: $audioProcessor.balance, in: -10...10, step: 1)
                        .foregroundColor(audioProcessor.isOutputMono ? .gray : .primary)
                }
                .fixedSize()
                .disabled(audioProcessor.isOutputMono)
                
                Spacer()
            }
            .padding()
            
            LevelMeters(audioProcessor: audioProcessor)
                .padding()
            
            RunButton(audioProcessor: audioProcessor)
                .padding()
            
            Spacer()
            
        }
        .hbaBackground()
        
    }
    
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(audioProcessor: audioProcessor)
    }
}
