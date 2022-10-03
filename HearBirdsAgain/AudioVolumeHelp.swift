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
                "Use the *iOS Audio Volume* slider to adjust the audio output volume of your iOS device. Note that you can also adjust the volume using the physical volume up and down buttons on your device.\n\nThe small AirPlay button to the right of the slider allows you to select an audio output destination. Most users will not need to use this control.")
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
