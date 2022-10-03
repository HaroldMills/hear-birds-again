//
//  ShowHelpButton.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct ShowHelpButton: View {
    
    @Binding var helpButtonsVisible: Bool

    private var buttonTitle: String {
        get {
            return helpButtonsVisible ? "Hide Help" : "Show Help"
        }
    }
    
    var body: some View {
        
        Button(buttonTitle) {
            helpButtonsVisible = !helpButtonsVisible
        }
        
    }
    
}

struct ShowHelpButton_Previews: PreviewProvider {
    static var previews: some View {
        ShowHelpButton(helpButtonsVisible: .constant(false))
    }
}
