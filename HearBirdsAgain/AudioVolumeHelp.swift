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
        
        VStack(alignment: .leading) {
            
            HelpTitle("iOS Audio Volume")
            
            Spacer()
            
            Text("""
Use the *iOS Audio Volume* slider to adjust the audio output volume of your iOS device. Note that you can also adjust the volume using the physical volume up and down buttons on your device.

If for typical settings of the iOS audio volume (e.g. ones appropriate for phone conversations or listening to music) the output of ***Hear Birds Again*** is too soft or too loud, try adjusting the gain setting on the app's *More Controls* tab. Note that if you use the recommended [high-fidelity binaural headset](https://hearbirdsagain.org/high-fidelity-binaural-headset/), it is unlikely that you will need to do this.

The small AirPlay button to the right of the *iOS Audio Volume* slider allows you to select an audio output destination. Most users will not need to use this control.
""")
            .padding()
            
            Spacer()
            
        }
        .hbaHelp(isPresented: $isPresented)
        
    }
    
}

struct AudioVolumeHelp_Previews: PreviewProvider {
    static var previews: some View {
        AudioVolumeHelp(isPresented: .constant(true))
    }
}
