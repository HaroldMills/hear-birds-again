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
                
                Text("""
If you experience technical problems with ***Hear Birds Again*** or have questions about the functioning of the app, please feel free to email us at support@hearbirdsagain.org.

There is also a ***Hear Birds Again*** [Google Groups email list](https://groups.google.com/g/hear-birds-again) that you can [join](https://hearbirdsagain.org/users-forum/) to communicate with other users and the development team. We hope to see you there!
""")
                .padding()
                
                
            }
            .hbaScrollbar()
            
            Rectangle()
                .frame(height: 45)
                .foregroundColor(.clear)
            
        }
        .hbaBackground()

    }
    
}

struct SupportInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        SupportInfoPage()
    }
}
