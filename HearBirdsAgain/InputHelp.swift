//
//  InputHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct InputHelp: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HelpTitle("Input")
            
            Spacer()
            
            Text(
                "The *Input* field shows the name of the current audio input device. The Hear Birds Again app will process audio from this device.")
            .padding()
            
            Spacer()
            
        }
        .hbaHelp(isPresented: $isPresented)
        
    }
    
}

struct InputHelp_Previews: PreviewProvider {
    static var previews: some View {
        InputHelp(isPresented: .constant(true))
    }
}
