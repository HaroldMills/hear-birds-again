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
            
            Text(
                "Use the *Pitch Shift* control to select how much the Hear Birds Again app lowers the frequencies of higher-pitched sounds. Select 1/2 to divide them by two, or equivalently to lower them by a musical interval of one octave. Select 1/3 to divide them by three, or lower them by an octave and a fifth. Select 1/4 to divide them by four, or lower them by two octaves.")
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
