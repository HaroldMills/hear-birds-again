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
        case controls
        case console
        case info
        case help
        case about
        case donate
    }
    
    @SceneStorage("HbaView.selectedTab") private var selectedTab = Tab.home
    
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

            ControlsView(audioProcessor: audioProcessor)
                .tabItem {
                    Label("Controls", systemImage: "slider.horizontal.3")
                        
                    }
                .tag(Tab.controls)
            
            if HbaApp.consoleTabVisible {
                ConsoleView(console: console)
                    .tabItem {
                        Label("Console", systemImage: "terminal")
                    }
                    .tag(Tab.console)
            }

            InfoView()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
                .tag(Tab.info)
            
//            HelpView()
//                .tabItem {
//                    Label("Help", systemImage: "questionmark.circle")
//                }
//                .tag(Tab.help)
            
//            AboutView()
//                .tabItem{
//                    Label("About", systemImage: "info.circle")
//                }
//                .tag(Tab.about)

//            DonateView()
//                .tabItem{
//                    Label("Donate", systemImage: "heart")
//                }
//                .tag(Tab.donate)

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
