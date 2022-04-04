//
//  ContentView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import SwiftUI


struct ContentView: View {
    
    @State private var pitchShift: Int = 2

    @ObservedObject var audioProcessor: AudioProcessor
    
    private var buttonTitle: String {
        get {
            return audioProcessor.running ? "Stop" : "Run"
        }
    }
    
    private var nonfatalErrorMessage: String {
        get {
            return "A nonfatal error occurred. The error message was: \(audioProcessor.nonfatalErrorMessage)"
        }
    }
    
    private var fatalErrorMessage: String {
        get {
            return "A fatal error occurred, so the app will now exit. The error message was: \(audioProcessor.fatalErrorMessage)"
        }
    }
    
    var body: some View {
        
        VStack {
            
            Text("Hear Birds Again")
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding()
            
            HStack {
                
                Text("Pitch Shift:")
            
                Picker("Pitch Shift", selection: $audioProcessor.pitchShift) {
                    Text("Two").tag(2)
                    Text("Three").tag(3)
                    Text("Four").tag(4)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                
            }
            .padding()
            
            HStack {
                
                Text("Window Type:")
                
                Picker("Window Type", selection: $audioProcessor.windowType) {
                    Text("Hann").tag(WindowType.Hann)
                    Text("SongFinder").tag(WindowType.SongFinder)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                
            }
            .padding()
            
            VStack {

                Text("Window Size:")
                
                HStack {

                    // Text("5")

                    Slider(value: $audioProcessor.windowSize, in: 5...50)

                    // Text("50")
                    
                    Text("\(audioProcessor.windowSize, specifier: "%.1f") ms")
                    
                }

            }
            .padding()

            Button(buttonTitle) {

                if (audioProcessor.running) {
                    audioProcessor.stop()
                } else {
                    audioProcessor.start()
                }

            }
            .padding()
            
        }
        .padding()
        .alert(nonfatalErrorMessage, isPresented: $audioProcessor.nonfatalErrorOccurred) {
            Button("OK", role: .cancel) {
                audioProcessor.nonfatalErrorOccurred = false
            }
        }
        .alert(fatalErrorMessage, isPresented: $audioProcessor.fatalErrorOccurred) {
            Button("OK", role: .cancel) {
                fatalError(fatalErrorMessage)
            }
        }

    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioProcessor: AudioProcessor())
    }
}
