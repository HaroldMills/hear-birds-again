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
            
            Text(
                "The *Output Level* meter shows the power level of the audio that the Hear Birds Again app is currently sending to the iOS operating system.\n\nThe level reflects all of the processing that the app performs, including filtering, pitch shifting, amplification, and balance processing. The level *does not* reflect amplification that iOS performs according to the *iOS Audio Volume* control.\n\nThe meter has one bar when output is monaural, and two bars when it is stereo.")
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
