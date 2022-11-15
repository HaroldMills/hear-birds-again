//
//  WelcomeInfoPage.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/12/22.
//

import SwiftUI

struct WelcomeInfoPage: View {
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading) {
                
                InfoPageTitle("Welcome!")
                
                Text("""
***Hear Birds Again*** is an iOS app for bird enthusiasts who can no longer hear high-pitched bird sounds, but who can still hear lower-pitched sounds reasonably well. In brief, it works by shifting high-pitched sounds into a lower range where you can hear them.
""")
                .padding()

                InfoPageImage("HappyUser", caption: "\"I'm so happy to hear the high-pitched bird songs again!\"")
                    .padding()
                
                Text("""
Both the app and its website [hearbirdsagain.org](https://hearbirdsagain.org) include documentation pertaining to the app. The in-app documentation includes detailed descriptions of the functions of app controls, but defers to the website for many details about other topics, such as [the problem the app solves](https://hearbirdsagain.org/problem-and-solutions/) and the [binaural headset](https://hearbirdsagain.org/binaural-headset/) that we strongly recommend using with the app. *If you want to make effective use of the app, please take the time to read both the in-app documentation and the web site.*

You're currently viewing the app's *Info* tab, which includes several pages of documentation. You can navigate among the pages by swiping left and right or tapping to the left or right of the row of dots near the bottom of the screen.

We hope you enjoy using ***Hear Birds Again***!
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

struct WelcomeInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeInfoPage()
    }
}
