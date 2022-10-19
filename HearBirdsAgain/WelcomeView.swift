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
                    
You're currently viewing the app's *Info* tab, which includes several pages of information. You can navigate among the pages by swiping left and right or tapping on the dots near the bottom of the tab. If you're using the app for the first time, please peruse the pages to familiarize yourself with their contents.
""")
                .padding()
                
                InfoSectionHeader("Will *Hear Birds Again* Help You?")
                
                Text("""
We strongly advise having your hearing tested by an audiologist and obtaining an audiogram, so that you know the frequencies at which your hearing becomes impaired. You may also visit [this web site](http://www.phys.unsw.edu.au/jw/hearing.html) to test your hearing online.

It will also be informative to listen to the [audio examples](https://hearbirdsagain.org/hear-for-yourself/) on our website where bird songs are played at normal pitch followed by pitch-lowered examples.

Below is an audiogram that depicts high frequency hearing loss due to aging (presbycusis). As you can see, the average 60 year-old exhibits substantial hearing loss above 3000 Hz. This is not good news for birders because the majority of songbirds have songs that fall in that range.
""")
                .padding()
                     
                Image("AgeRelatedHearingLoss")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .padding()
                
                Text("""
Below is an audiogram of a hypothetical optimal user. Note that hearing in both ears is reasonably good to 2000 Hz, while hearing above 3000 Hz is significantly compromised. Given this curve, it follows that our app should be adjusted to lower bird songs whose pitch falls above around 3000 Hz.
""")
                .padding()
                
                Image("Audiogram")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .padding()
                
                Text("""
Please visit [our website](https://hearbirdsagain.org) for more details about age-related hearing loss as well as damage due to loud noises.
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
