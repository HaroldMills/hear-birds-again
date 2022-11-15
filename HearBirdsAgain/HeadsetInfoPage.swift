//
//  HeadsetInfoPage.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/13/22.
//

import SwiftUI

struct HeadsetInfoPage: View {

    var body: some View {

        VStack {

            VStack(alignment: .leading) {

                Group {
                    
                    InfoPageTitle("The Binaural Headset")
                    
                    Text("""
    For best results, ***Hear Birds Again*** should be used in conjunction with a special “binaural headset” that allows users to judge directions and distances of pitch-lowered bird songs in 3D space, and then actually “move toward and find the singers.”
    """)
                    .padding()
                    
                    InfoPageImage("HeadsetSide")
                        .padding()

                    Text("""
Our recommended headset is [described here](https://hearbirdsagain.org/binaural-headset/) and ordering instructions are provided. It utilizes special low-noise microphones suitable for detecting subtle and distant bird songs. Be forewarned that some assembly will be required, including simple braiding of the cables and mounting the mics on the earphones.
""")
                    .padding()
                    
                    InfoPageImage("BinauralHeadset")
                        .padding()
                    
                    Text("""
Unfortunately, no fully-assembled headsets of this type are currently available in the marketplace ([with one possible exception](https://hearbirdsagain.org/ambeo-smart-headset), although we are confident that high-quality plug-and-play headsets with built-in binaural mics eventually become available.
""")
                    .padding()
                }
                    
                InfoPageSectionHeader("WARNING!: It Is Important to Properly Adjust Settings for the Rode AI-Micro Audio interface in Order to Prevent Loud Feedback Squeal.")
                    .foregroundColor(.red)
                    
                Text("""
Our recommended headset requires the use of the Rode AI-Micro interface, which will route the headset mics inputs into one’s mobile device and the device’s output (the pitch-lowered bird songs) back to the Koss Earphones. In order for this to work properly, it will be necessary for you to download Rode’s RodeCentral application and then adjust the settings. The procedure is as follows:

1. Download RodeCentral and then open the app.
                
2. Connect your Rode AI Micro interface to your mobile device. RodeCentral should then automatically detect the audio interface.
                
3. TURN OFF the “Direct Monitor” option (the bottommost setting). CAUTION: If left enabled, you will probably experience loud feedback squeal!
                
4. Adjust other settings as as shown in the following screenshot of the RodeCentral user interface:
""")
                .padding()
                    
                InfoPageImage("RodeCentralConfig")
                    .padding()
                    
                Text("""
Once the direct monitoring setting has been disabled, everything should work fine and you should not have to use the RodeCentral app again, except perhaps to occasionally check for updates to the Rode AI Micro firmware (RodeCentral automatically detects if your current firmware is out of date).
""")
                .padding()
                    
                InfoPageSectionHeader("Other Input and Output Options")
                
                Text("""
While our binaural headset is vastly superior to other options, it is possible to test our app using your mobile device’s built-in mics along with wired or wireless earbuds and headphones. Be aware, however, that this is not an optimal solution and results will vary greatly depending on a number of factors.

While our binaural headset is vastly superior to other options, it is possible to test our app using your mobile device’s built-in mics along with wired or wireless earbuds and headphones. Be aware, however, that this is not an optimal solution and results will vary greatly depending on a number of factors.

The biggest problem is that the built-in mics do not provide accurate spatial audio, so it will be nearly impossible to determine the directions and distances of incoming pitch-lowered songs. The built-in mics also have high internal noise, which can mask faint bird songs.

Furthermore, if bluetooth earbuds or headphones are used that have built-in mics, those mics are likely to be enabled and will probably result in low quality audio, with no spatial sense whatsoever.

To make matters worse, bluetooth has "latency issues," meaning there is usually a noticeable delay in the transmission of pitch-lowered signals. This may be particularly annoying if you are with other people and the high-pitched portions of their voices are delayed with respect to the lower pitched aspects of their voices that you are hearing normally. For testing without the recommended binaural headset, we advise using wired earbuds (without mics), coupled with the mobile device's built-in mics. Note that if you're using an iphone, you should orient it horizontally so as to engage the internal stereo mics. This will result in a pleasing sense of space though without the accuracy necessary to actually find and observe singing birds.
""")
                .padding()
                    
            }
            .hbaScrollbar()

            InfoPageIndexSpacer()

        }
        .hbaBackground()

    }

}

struct HeadsetInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        HeadsetInfoPage()
    }
}
