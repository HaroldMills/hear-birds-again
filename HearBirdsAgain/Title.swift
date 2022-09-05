//
//  Title.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/5/22.
//

import SwiftUI

struct _AppName: View {

    var body: some View {
        Text("Hear Birds Again")
            .font(.system(size: 35, weight: .bold, design: .default))
    }
    
}

struct Title: View {
    
    var subtitle: String?

    var body: some View {
        
        if let subtitle = self.subtitle {
            
            VStack {
                
                _AppName()
                
                Text(subtitle)
                    .font(.subheadline)
                
            }
            
        } else {
            
            _AppName()
            
        }
        
    }
    
}

struct Title_Previews: PreviewProvider {
    static var previews: some View {
        Title()
    }
}
