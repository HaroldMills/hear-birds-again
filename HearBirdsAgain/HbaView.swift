//
//  ContentView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 3/25/22.
//


import SwiftUI


struct HbaView: View {
    
    
    @ObservedObject var audioProcessor: AudioProcessor
    @ObservedObject var console: Console
    @ObservedObject var errors: Errors
    let saveAction: () -> Void

    enum Tab: String {
        case home
        case test
        case console
        case help
    }
    
    @SceneStorage("HbaView.selectedTab") private var selectedTab = Tab.home
    
    private let testTabVisible = false

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
    
    // So we can monitor scene phase changes for saving processor state
    // (see `.onChange` view modifier below).
    @Environment(\.scenePhase) private var scenePhase
    
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
            
            ConsoleView(console: console)
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
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }

    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HbaView(audioProcessor: audioProcessor, console: console, errors: errors, saveAction: {})
    }
}
