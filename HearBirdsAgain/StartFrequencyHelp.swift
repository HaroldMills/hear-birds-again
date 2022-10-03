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
        
        VStack {
            
            Title("Start Frequency")
            
            Spacer()
            
            Text(
                "Use the Start Frequency control to select the frequency above which the Hear Birds Again app will shift sounds down in pitch. Note that the app removes sounds whose frequencies are below the start frequency, assuming that you will hear them directly.")
            .padding()
            
            Spacer()
            
            Button("Close") {
                isPresented = false
            }
            
            Spacer()
            
        }
        .hbaScrollbar()
        .hbaBackground()
        
    }
    
}

struct StartFrequencyHelp_Previews: PreviewProvider {
    static var previews: some View {
        StartFrequencyHelp(isPresented: .constant(true))
    }
}
