//
//  InputGainHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct InputGainHelp: View {
    
    @Binding var isPresented: Bool

    var body: some View {
        
        VStack {
            
            Title("Input Gain")
            
            Spacer()
            
            Text(
                "Use the Input Gain control to set the gain of the current audio input device. Note that not all input devices have a gain setting, and this control is displayed only for those that do.\n\nThe Input Gain control is only enabled when the Extra Gain control value is 0 dB. This ensures that you use input device gain instead of extra gain whenever possible, which maximizes audio quality.")
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

struct InputGainHelp_Previews: PreviewProvider {
    static var previews: some View {
        InputGainHelp(isPresented: .constant(true))
    }
}
