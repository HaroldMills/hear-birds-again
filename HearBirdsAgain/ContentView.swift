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
    @ObservedObject var errors: Errors
    
    
    enum Tab: String {
        case home
        case test
        case console
        case help
    }
    
    @SceneStorage("ContentView.selectedTab") private var selectedTab = Tab.home
    
    private let includeTestTab = false
    
    // The AudioProcessor is currently the authority for the values of
    // its properties, rather than the UI, which seems best to me.
    // Is there some way we can arrange for AudioProcessor state to be
    // saved and restored at the same time that UI state like the
    // selected tab is saved and restored via @SceneStorage?
    
    // When the following is uncommented and the pitch shift picker's
    // selection is $pitchShift, the pitchShift.didSet method is not
    // called when the picker value changes. On the other hand, when
    // the pitch shift picker's selection is $audioProcessor.pitchShift,
    // the audioProcessor.pitchShift.didSet method *is* called when the
    // picker value changes. Why the difference?
//    @SceneStorage("ContentView.pitchShift")
//    private var pitchShift: Int = 2 {
//        didSet {
//            print("ContentView.pitchShift set to \(pitchShift)")
//            audioProcessor.pitchShift = pitchShift
//        }
//    }


    private var buttonTitle: String {
        get {
            return audioProcessor.running ? "Stop" : "Run"
        }
    }
    
    private var nonfatalErrorMessage: String {
        get {
            return "A nonfatal error occurred. The error message was: \(errors.nonfatalErrorMessage)"
        }
    }
    
    private var fatalErrorMessage: String {
        get {
            return "A fatal error occurred, so the app will now exit. The error message was: \(errors.fatalErrorMessage)"
        }
    }
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
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
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)
            .background(
                Image("BlackAndWhiteWarbler")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.15))

            if (includeTestTab) {
                
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
                .tag(Tab.test)
                .background(
                    Image("BlackAndWhiteWarbler")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.15))
                
            }
            
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
            .tag(Tab.console)

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
            .tag(Tab.help)
            .background(
                Image("BlackAndWhiteWarbler")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.15))

        }
        .alert(nonfatalErrorMessage, isPresented: $errors.nonfatalErrorOccurred) {
            Button("OK", role: .cancel) {
                errors.nonfatalErrorOccurred = false
            }
        }
        .alert(fatalErrorMessage, isPresented: $errors.fatalErrorOccurred) {
            Button("OK", role: .cancel) {
                fatalError(fatalErrorMessage)
            }
        }

    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioProcessor: audioProcessor, logger: logger, errors: errors)
    }
}
