//
//  HomeView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    
    private var buttonTitle: String {
        get {
            return audioProcessor.running ? "Stop" : "Run"
        }
    }
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text("Hear Birds Again")
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding()
            
            HStack {
                
                Text("Pitch Shift:")
            
                Picker("Pitch Shift", selection: $audioProcessor.pitchShift) {
                // Picker("Pitch Shift", selection: $pitchShift) {
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
                }
                .fixedSize()
                Spacer()
            }
            .padding()
            
            VStack(spacing: 6) {
                ForEach(0..<$audioProcessor.outputLevels.count, id: \.self) { i in
                    LevelMeter(level: $audioProcessor.outputLevels[i], minLevel: -80, maxLevel: 0, segmentSize: 5)
                }
            }
            .padding()

            Button(buttonTitle) {

                if (audioProcessor.running) {
                    audioProcessor.stop()
                } else {
                    // print("ContentView: setting pitch shift to \(pitchShift)")
                    // audioProcessor.pitchShift = pitchShift
                    audioProcessor.start()
                }

            }
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
