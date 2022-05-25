//
//  ContentView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import SwiftUI


struct ContentView: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    @ObservedObject var logger: Logger
    
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
        
        TabView {
            
            VStack {
                
                Spacer()
                
                Text("Hear Birds Again")
                    .font(.system(size: 35, weight: .bold, design: .default))
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
                
                VStack {
                    HStack {
                        Text("Gain:")
                        Slider(value: $audioProcessor.gain, in: 0...24)
                    }
                    Text(String(format: "%.1f dB", audioProcessor.gain))
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
                
                Spacer()
                
//                Text(
//                    "If you find this app useful, please [donate](https://hearbirdsagain.org/donate/) to support its continued development and maintenance.")
//
//                Spacer()
                
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .background(
                Image("BlackAndWhiteWarbler")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.15))

            VStack {
                
                Spacer()
                
                Text("Hear Birds Again")
                    .font(.system(size: 35, weight: .bold, design: .default))
                    .padding()
                
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

                Spacer()
                
            }
            .tabItem {
                Label("Test", systemImage: "slider.horizontal.3")
            }
            .background(
                Image("BlackAndWhiteWarbler")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.15))
            
            ScrollView {
                
                VStack {
                    
                    HStack {
                        
                        Text(logger.logText)
                            .font(Font.system(size: 16).monospaced())
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                        
                        Spacer()
                        
                    }
                    
                    Spacer()
                    
                }
                
            }
            .tabItem {
                Label("Console", systemImage: "terminal")
            }

            VStack {
                
                Spacer()
                
                Text("Hear Birds Again")
                    .font(.system(size: 35, weight: .bold, design: .default))
                    .padding()
                
                Text("Help is on the way!")
                    .padding()
                
                Spacer()
                
            }
            .tabItem {
                Label("Help", systemImage: "questionmark.circle")
            }
            .background(
                Image("BlackAndWhiteWarbler")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.15))

        }
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
        ContentView(audioProcessor: AudioProcessor(), logger: Logger())
    }
}
