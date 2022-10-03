//
//  GainHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct GainHelp: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    @Binding var isPresented: Bool

    var body: some View {
        
        VStack {
            
            if audioProcessor.isInputGainSettable {
                Title("Extra Gain")
            } else {
                Title("Gain")
            }
            
            Spacer()
            
            if audioProcessor.isInputGainSettable {
                
                Text(
                    "Use the Extra Gain control to boost the output volume if the Input Gain control and the iOS Audio Volume slider together are inadequate.\n\nThe Extra Gain control is only enabled when the Input Gain control value is 100 percent. This ensures that you use input device gain instead of extra gain whenever possible, which maximizes audio quality.")
                .padding()
                
            } else {
                
                Text(
                    "Use the Gain control to boost the output volume if the iOS Audio Volume slider alone is inadequate.")
                .padding()
                
            }
            
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

struct GainHelp_Previews: PreviewProvider {
    static var previews: some View {
        GainHelp(audioProcessor: audioProcessor, isPresented: .constant(true))
    }
}
