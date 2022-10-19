//
//  UiView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/17/22.
//

import SwiftUI

struct UiView: View {
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading) {
                
                InfoTitle("The User Interface")
    
                Text("""
The ***Hear Birds Again*** user interface comprises three tabs, named *Home*, *Controls*, and *Info*. Only one tab is visible at a time, according to the one selected at the bottom of the screen. You are currently viewing the *Info* tab, which includes several pages of information about the app.

During normal use, you'll probably view the *Home* tab most often, since it includes more-frequently used app controls. The *Controls* tab includes less-frequently used controls. On both the *Home* and *Controls* tabs, most controls are accompanied by a small help button (a question mark in a circle) that you can tap to see an explanation of the control's function.
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

struct UiView_Previews: PreviewProvider {
    static var previews: some View {
        UiView()
    }
}
