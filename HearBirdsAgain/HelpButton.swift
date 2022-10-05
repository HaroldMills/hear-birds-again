//
//  HelpButton.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/5/22.
//

import SwiftUI

struct HelpButton: View {
    
    var action: () -> Void

    var body: some View {
        Button(action: action, label: {
            Image(systemName: "questionmark.circle")
        })
    }
    
}

struct HelpButton_Previews: PreviewProvider {
    static var previews: some View {
        HelpButton(action: {})
    }
}
