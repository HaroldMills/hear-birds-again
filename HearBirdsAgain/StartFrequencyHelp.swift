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
                "Use the Start Frequency control to select the frequency above which sounds are shifted down in pitch. Note that sounds whose frequencies are below the start frequency are removed, assuming that you will hear them directly.")
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
