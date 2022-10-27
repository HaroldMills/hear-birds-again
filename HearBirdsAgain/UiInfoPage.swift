//
//  UiInfoPage.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/17/22.
//

import SwiftUI

struct UiInfoPage: View {
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading) {
                
                InfoPageTitle("The User Interface")
    
                Text("""
The ***Hear Birds Again*** user interface comprises three tabs, named *Home*, *Controls*, and *Info*. Only one tab is visible at a time, according to the icon you select at the bottom of the screen. You are currently viewing the *Info* tab.

You'll probably use the *Home* tab most often, since it includes the most frequently-used app controls. The *Controls* tab includes less-frequently used controls. On both the *Home* and *Controls* tabs, most controls are accompanied by a small help button (a question mark in a circle) that you can tap to see a detailed explanation of the control's function.
""")
                .padding()
                
            }
            .hbaScrollbar()
            
            Rectangle()
                .frame(height: 45)
                .foregroundColor(.clear)
            
        }
        .hbaBackground()
        
    }
    
}

struct UiInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        UiInfoPage()
    }
}
