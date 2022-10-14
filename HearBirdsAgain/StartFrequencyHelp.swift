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
            
            Text(
                "Use the *Start Frequency* control to select the frequency above which the Hear Birds Again app shifts sounds down in pitch. Note that the app filters out input sounds whose frequencies are below the start frequency, assuming that you will hear them directly through the air.")
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
