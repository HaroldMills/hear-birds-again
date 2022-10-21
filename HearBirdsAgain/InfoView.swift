//
//  InfoView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/12/22.
//

import SwiftUI

struct InfoView: View {
    
    var body: some View {
        
        TabView {
            WelcomeInfoPage()
            WillHbaHelpInfoPage()
            HeadsetInfoPage()
            UiInfoPage()
            ProjectInfoPage()
            SupportInfoPage()
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))

    }

}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
