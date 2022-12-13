//
//  OutputLevelHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct OutputLevelHelp: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HelpTitle("Output Level")
            
            Spacer()
            
            Text("""
The *Output Level* meter shows the power level of the audio that ***Hear Birds Again*** is currently sending to the iOS operating system. The level reflects all of the processing that the app performs, including filtering, pitch shifting, amplification, and balance processing. It *does not* reflect amplification that iOS performs according to the *iOS Audio Volume* control.\n\nThe meter has one bar when output is monaural, and two bars when output is stereo.

You can look at the meter to confirm that ***Hear Birds Again*** is receiving audio from the mics, either those mounted on a [binaural headset](https://hearbirdsagain.org/binaural-headset/) or those built into your iOS device or auxiliary earbuds or headphones. If the app is receiving audio, you will see activity in the meter. If the app is not receiving audio, the meter will be still.

If the output level displayed in the meter is consistently low (towards the left end of the green region, say even when you make pishing sounds) or high (jumping into the red region), try raising or lowering the gain on the *More Controls* tab to suit.
""")
            .padding()
            
            Spacer()
            
        }
        .hbaHelp(isPresented: $isPresented)

    }
    
}

struct OutputLevelHelp_Previews: PreviewProvider {
    static var previews: some View {
        OutputLevelHelp(isPresented: .constant(true))
    }
}
