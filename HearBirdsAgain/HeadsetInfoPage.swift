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
                
                InfoPageTitle("The Binaural Headset")
                
                Text("""
For best results, we recommend using ***Hear Birds Again*** with a special *binaural headset* (see photo below) that allows you to accurately determine the direction of a singing bird from its pitch-lowered song. The headset was designed by Lang Elliott specifically for use with this app, and uses special low-noise microphone elements mounted at each ear for excellent performance.
""")
                .padding()

                VStack {
                    
                    Image("BinauralHeadset")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    HStack {
                        Text("Recommended binaural headset")
                            .font(.caption)
                        Spacer()
                    }
                    
                }
                .padding()
    
                Text("""
While it is possible to use the app with off-the-shelf earbuds and headsets, and even with the built-in iPhone and iPad microphones, we recommend this only for test purposes, since the binaural headset provides a much better user experience. Please see the [binaural headset](https://hearbirdsagain.org/binaural-headset/) section of the app's website for more information about the headset, including ordering and assembly instructions.
""")
                .padding()
                
                Text("""
IMPORTANT: Do not attempt to use the binaural headset without first assembling and configuring it according to the instructions on the website. Failure to configure the headset properly before use may cause it to produce loud feedback squeals.
""")
                .padding()
                .foregroundColor(.red)
                
                Text("""
Please note that the ***Hear Birds Again*** project receives no income from sales of the binaural headset, which is available only from third parties.
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

//struct HeadsetInfoPage: View {
//
//    var body: some View {
//
//        VStack {
//
//            VStack(alignment: .leading) {
//
//                InfoPageTitle("The Binaural Headset")
//
//                Text("""
//For optimal results, ***Hear Birds Again*** should be used in conjunction with a special "binaural headset" that will allow users to judge directions and distances of pitch-lowered bird songs in 3D space, and then actually "go find the singers".
//
//Our recommended headset is described [here](https://hearbirdsagain.org/binaural-headset/) and ordering instructions are provided. It utilizes special low-noise microphones suitable for detecting subtle and distant bird songs. Some assembly will be is required, including simple braiding of the cables and mounting the mics on the earphones.
//""")
//                .padding()
//
//                VStack {
//
//                    Image("BinauralHeadset")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//
//                    HStack {
//                        Text("Recommended binaural headset")
//                            .font(.caption)
//                        Spacer()
//                    }
//
//                }
//                .padding()
//
//                Text("""
//Unfortunately, no fully-assembled headsets of this type are currently available in the marketplace, though we are confident that high-quality plug-and-play headsets with built-in binaural mics will eventually become available.
//""")
//                .padding()
//
//                InfoPageSectionHeader("Other Input and Output Options")
//
//                Text("""
//While our binaural headset is vastly superior to other options, it is possible to test our app using your mobile device's built-in mics along with wired or wireless earbuds and headphones. Be aware, however, that this is not an optimal solution and results will vary greatly depending on a number of factors.
//
//The biggest problem is that the built-in mics do not provide accurate spatial audio, so it will be nearly impossible to determine the directions and distances of incoming pitch-lowered songs. The built-in mics also have high internal noise, which can mask faint bird songs.
//
//Furthermore, if Bluetooth earbuds or headphones are used that have built-in mics, those mics may very well be enabled and the result will probably be of very low quality, with no spatial sense whatsoever.
//
//To make matters worse, Bluetooth has "latency issues", meaning there is usually a noticeable delay in the transmission of pitch-lowered signals. This may be particularly annoying if you are with other people and the high-pitched portions of their voices are delayed with respect to the lower-pitched aspects of their voices that you are hearing normally.
//
//For testing without the recommended binaural headset, we advise using wired earbuds (without mics), coupled with the mobile device's built-in mics. Furthermore, if you're using an iPhone, orient it horizontally so as to engage the internal stereo mics, which will provide a pleasing sense of space though without the accuracy necessary to actually find and observe singing birds.
//""")
//                .padding()
//
//            }
//            .hbaScrollbar()
//
//            Rectangle()
//                .frame(height: 45)
//                .foregroundColor(.clear)
//
//        }
//        .hbaBackground()
//
//    }
//
//}

struct HeadsetInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        HeadsetInfoPage()
    }
}
