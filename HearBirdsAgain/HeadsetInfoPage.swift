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
                    
                    InfoPageTitle("Binaural Headsets")
                    
                    Text("""
For best results, Hear Birds Again should be used in conjunction with a special “binaural headset” that has microphones mounted near each ear and that allows users to judge directions and distances of pitch-lowered bird songs in 3D space, and then actually “move toward and find the singers.”

Unfortunately, there are no “perfect” binaural headsets currently available in the marketplace, but there are two workable solutions:
""")
                    .padding()
                    
                    InfoPageSectionHeader("1. The Ambeo Smart Headset")
                    
                    InfoPageImage("AmbeoHeadset")
                        .padding()
                    
                    Text("""
Although no longer being manufactured, the Ambeo Smart Headset, [described here](https://hearbirdsagain.org/ambeo-smart-headset), is still available in the marketplace (at least for awhile) and provides an inexpensive “plug-and-play” binaural headset solution, with a purchase price as low as $50 US. The primary drawback is that it is equipped with microphones that are notably hissy, which can be annoying in quiet outdoor situations and may also be loud enough to obscure faint and distant bird songs. The Ambeo also plugs the ears somewhat, which may slightly muffle one’s normal hearing. In spite of these problems, the Ambeo provides a reasonably decent binaural listening experience.
""")
                    .padding()
                    
                    InfoPageSectionHeader("2. The High-Fidelity Binaural Headset (kit)")
                    
                    InfoPageImage("HiFiHeadset")
                        .padding()
                    
                    Text("""
If you are a serious birder who desires a high-fidelity headset equipped with super low-noise microphones and earphones that do not plug one’s ears, we suggest you acquire our recommended **High-Fidelity Binaural Headset**, [described here](https://hearbirdsagain.org/high-fidelity-binaural-headset), which is available in kit form. While it is expensive in comparison to the Ambeo (around $175 vs $50) and requires some assembly (mostly the final twisting of cables), it undoubtedly provides the most pleasurable user-experience in the field, including superior “localization” of the high-pitched singers. If you’re really into birds and are unafraid of the assembly aspect, we strongly suggest you take this route.
""")
                    .padding()
                    
                }
                    
                InfoPageSectionHeader("Other Input and Output Options")
                
                Text("""
    While true binaural headset options such as those described above are necessary for a satisfying “3D” experience in the field, it is possible to test our app using your mobile device’s built-in mics along with wired or wireless earbuds and headphones. Be aware, however, that this is not an optimal solution and results will vary greatly depending on a number of factors.

The biggest problem is that the built-in mics do not provide accurate spatial audio, so it will be nearly impossible to determine the directions and distances of incoming pitch-lowered songs. The built-in mics also have high internal noise, which can mask faint bird songs.

Furthermore, if bluetooth earbuds or headphones are used that have built-in mics, those mics are likely to be enabled and will probably result in low quality audio, with no spatial sense whatsoever.

To make matters worse, bluetooth has "latency issues," meaning there is usually a noticeable delay in the transmission of pitch-lowered signals. This may be particularly annoying if you are with other people and the high-pitched portions of their voices are delayed with respect to the lower pitched aspects of their voices that you are hearing normally.

For testing without a binaural headset, we advise using wired earbuds (without mics), coupled with the mobile device's built-in mics. Note that if you're using an iPhone, you should orient it horizontally so as to engage the internal stereo mics. This will result in a pleasing sense of space though without the accuracy necessary to actually find and observe singing birds.
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
