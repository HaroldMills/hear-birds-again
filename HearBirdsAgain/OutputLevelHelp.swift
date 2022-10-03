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
        
        VStack {
            
            Title("Output Level")
            
            Spacer()
            
            Text(
                "The Output Level meter shows the power level of the audio that the Hear Birds Again app is currently sending to the iOS operating system. The level reflects all of the processing that the app performs, including any amplification indicated by the gain and balance controls. The level *does not* reflect amplification that iOS performs according to the iOS Audio Volume control.")
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

struct OutputLevelHelp_Previews: PreviewProvider {
    static var previews: some View {
        OutputLevelHelp(isPresented: .constant(true))
    }
}
