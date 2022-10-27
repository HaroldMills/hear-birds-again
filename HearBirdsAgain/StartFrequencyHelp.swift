//
//  StartFrequencyHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct StartFrequencyHelp: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HelpTitle("Start Frequency")
            
            Spacer()
            
            Text("""
Use the *Start Frequency* control to select the frequency above which ***Hear Birds Again*** shifts sounds down in pitch. Note that the app filters out input sounds whose frequencies are below the start frequency, assuming that you will hear them directly. This works particularly well with the recommended open air [binaural headset](https://hearbirdsagain.org/binaural-headset/). Note also that the frequency values indicated in the control have units of 1 kilohertz (abbreviated *kHz*), with 1 kilohertz being 1000 Hertz (abbreviated *Hz*).

If you will be using ***Hear Birds Again***, we strongly recommend having your hearing tested by an audiologist. They will provide you with an *audiogram*, a plot of the sensitivity of your hearing versus frequency. You can then adjust the start frequency according to the audiogram. For example, if the audiogram indicates that your hearing loss becomes substantial at 3000 Hz, you might initially select a 3 kHz start frequency. However, as you listen to the pitch-lowered songs of various species singing near that frequency, be sure to try lower and/or higher start frequency settings to determine which one actually works best for you.
""")
            .padding()
            
            Spacer()
            
        }
        .hbaHelp(isPresented: $isPresented)

    }
    
}

struct StartFrequencyHelp_Previews: PreviewProvider {
    static var previews: some View {
        StartFrequencyHelp(isPresented: .constant(true))
    }
}
