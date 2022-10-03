//
//  AudioVolumeHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct AudioVolumeHelp: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack {
            
            Title("iOS Audio Volume")
            
            Spacer()
            
            Text(
                "The iOS Audio Volume slider is an Apple-supplied control that allows you to adjust the audio volume of your device. Note that you can also control the volume using the physical up and down volume buttons on your device.\n\nThe small AirPlay button to the right of the slider is another Apple-supplied control that allows you to select an audio destination. Most users will probably not need to use this control.")
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

struct AudioVolumeHelp_Previews: PreviewProvider {
    static var previews: some View {
        AudioVolumeHelp(isPresented: .constant(true))
    }
}
