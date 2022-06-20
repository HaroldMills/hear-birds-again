//
//  ContentView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import SwiftUI


struct HbaView: View {
    
    
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
    
    private let testTabVisible = false
    
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
            
            HomeView(audioProcessor: audioProcessor)
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            if (testTabVisible) {
                TestView(audioProcessor: audioProcessor)
                .tabItem {
                    Label("Test", systemImage: "slider.horizontal.3")
                }
                .tag(Tab.test)
            }
            
            ConsoleView()
            .tabItem {
                Label("Console", systemImage: "terminal")
            }
            .tag(Tab.console)

            HelpView()
            .tabItem {
                Label("Help", systemImage: "questionmark.circle")
            }
            .tag(Tab.help)

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
        HbaView(audioProcessor: audioProcessor, logger: logger, errors: errors)
    }
}
