//
//  InfoView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/12/22.
//

import SwiftUI

struct InfoView: View {
    
    let saveAction: () -> Void

    enum Tab: String {
        case welcome
        case willHbaHelp
        case headset
        case ui
        case project
        case support
    }
    
    @SceneStorage("InfoView.selectedTab") private var selectedTab = Tab.headset

    // So we can monitor scene phase changes for saving processor state
    // (see `.onChange` view modifier below).
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            WelcomeInfoPage()
                .tag(Tab.welcome)
            
            WillHbaHelpInfoPage()
                .tag(Tab.willHbaHelp)
            
            HeadsetInfoPage()
                .tag(Tab.headset)
            
            UiInfoPage()
                .tag(Tab.ui)
            
            ProjectInfoPage()
                .tag(Tab.project)
            
            SupportInfoPage()
                .tag(Tab.support)
            
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }

    }

}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(saveAction: {})
    }
}
