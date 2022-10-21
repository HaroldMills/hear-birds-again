//
//  PitchShiftHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/28/22.
//

import SwiftUI

struct PitchShiftHelp: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HelpTitle("Pitch Shift")
            
            Spacer()
            
            Text("""
Use the *Pitch Shift* control to select how much ***Hear Birds Again*** lowers the frequencies of higher-pitched sounds. Select 1/2 to divide them by two, or equivalently to lower them by a musical interval of one octave. Select 1/3 to divide them by three, or lower them by an octave and a fifth. Select 1/4 to divide them by four, or lower them by two octaves.

Note that when you use the recommended open air [binaural headset](https://hearbirdsagain.org/binaural-headset/) with this app, there is significant leakage of pitch-lowered songs from the earphones back into the mics, and if the leaked songs are sufficiently high-pitched the app will pitch-lower them a second time. In practical terms, this means that the 1/2 setting also includes 1/4-shifted versions of sufficiently high-pitched songs, which makes the 1/2 setting good for detecting high-pitched bird songs over a very wide range of frequencies. Nonethess, we encourage you to try out the 1/3 and 1/4 settings also.
""")
            .padding()
            
            Spacer()
            
        }
        .hbaHelp(isPresented: $isPresented)

    }
    
}

struct PitchShiftHelp_Previews: PreviewProvider {
    static var previews: some View {
        PitchShiftHelp(isPresented: .constant(true))
    }
}
