//
//  SupportInfoPage.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/19/22.
//

import SwiftUI

struct SupportInfoPage: View {
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading) {
                
                InfoPageTitle("Support")
                
                InfoPageImage("Support")
                    .padding()
                
                Text("""
If you experience technical problems with ***Hear Birds Again*** or have questions about how to use it, please feel free to email us at support@hearbirdsagain.org.

There is also a [Google group](https://groups.google.com/g/hear-birds-again) named *Hear Birds Again* that you can [join](https://support.google.com/groups/answer/1067205) to communicate with other users and the development team. You can post messages to and receive messages from the group either via email or on the group's [website](https://groups.google.com/g/hear-birds-again). We hope to see you there!
""")
                .padding()
                
                
            }
            .hbaScrollbar()
            
            InfoPageIndexSpacer()
            
        }
        .hbaBackground()

    }
    
}

struct SupportInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        SupportInfoPage()
    }
}
