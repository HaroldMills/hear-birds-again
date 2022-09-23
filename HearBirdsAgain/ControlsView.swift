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
    
    var isInputGainControlVisible: Bool {
        return audioProcessor.isInputGainSettable
    }
    
    var isInputGainControlEnabled: Bool {
        isInputGainControlVisible && audioProcessor.appGain == 0
    }
    
    private var appGainControlName: String {
        get {
            return audioProcessor.isInputGainSettable ? "Extra Gain" : "Gain"
        }
    }
    
    var isAppGainControlEnabled: Bool {
        return !isInputGainControlVisible || audioProcessor.inputGain == 100
    }
    
    var isBalanceControlVisible: Bool {
        return !audioProcessor.isOutputMono
    }
    
    var body: some View {
        
        VStack {
            
            Title("Hear Birds Again", subtitle: "Less-Frequently Used Controls")
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

            Text("Input: \(audioProcessor.inputName)")
                .padding()
            
            if isInputGainControlVisible {
                HStack {
                    Spacer()
                    VStack {
                        Stepper("Input Gain: \(audioProcessor.inputGain.formatted()) %", value: $audioProcessor.inputGain, in: 0...100, step: 5)
                            .foregroundColor(isInputGainControlEnabled ? .primary : .gray)
                    }
                    .fixedSize()
                    .disabled(!isInputGainControlEnabled)
                    Spacer()
                }
                .padding()
            }

            HStack {
                Spacer()
                VStack {
                    Stepper("\(appGainControlName): \(audioProcessor.appGain.formatted()) dB", value: $audioProcessor.appGain, in: 0...20)
                        .foregroundColor(isAppGainControlEnabled ? .primary : .gray)
                }
                .fixedSize()
                .disabled(!isAppGainControlEnabled)
                Spacer()
            }
            .padding()
            
            if isBalanceControlVisible {
                HStack {
                    Spacer()
                    VStack {
                        Stepper("Balance: \(audioProcessor.balance.formatted()) dB", value: $audioProcessor.balance, in: -10...10, step: 1)
                    }
                    .fixedSize()
                    Spacer()
                }
                .padding()
            }
            
            VStack {
                Text("Output Level:")
                LevelMeters(audioProcessor: audioProcessor)
            }
            .padding()

            RunButton(audioProcessor: audioProcessor)
                .padding()
            
        }
        .hbaScrollbar()
        .hbaBackground()
            
    }
    
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(audioProcessor: audioProcessor)
    }
}
