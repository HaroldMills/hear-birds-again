//
//  WelcomeView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/12/22.
//

import SwiftUI

struct WelcomeView: View {
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading) {
                
                InfoTitle("Welcome!")
                
                Text("""
    ***Hear Birds Again*** is a mobile application for bird enthusiasts who can no longer hear high-pitched bird songs, but who still have reasonably good hearing in the lower range. In brief, it works by lowering high-pitched songs into a range where they can be heard.
    
    Please visit [our website](https://hearbirdsagain.org) for a detailed discussion of the reasoning behind the creation of our app.
    
    **Will** ***Hear Birds Again*** **Help You?**
    
    We strongly advise having your hearing tested by an audiologist and obtaining and audiogram, so that you know the frequencies at which your hearing becomes impaired. You may also visit [this web site](https://www.starkey.com/online-hearing-test) to test your hearing online.
    
    It will also be informative to check out the [audio examples](https://hearbirdsagain.org/hear-for-yourself/) on our web site where bird songs are played at normal pitch followed by pitch-lowered examples.
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

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
