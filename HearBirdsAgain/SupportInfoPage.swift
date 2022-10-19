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
If you experience technical problems with ***Hear Birds Again*** or have questions about the functioning of the app, please email us at support@hearbirdsagain.org.
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
