//
//  Title.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/5/22.
//

import SwiftUI

struct _Title: View {

    var title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.title)
            .fontWeight(.bold)
            .padding([.top], 20)
    }
    
}

struct Title: View {
    
    var title: String
    var subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        
        if let subtitle = self.subtitle {
            
            VStack {
                
                _Title(title)
                
                Text(subtitle)
                    .font(.subheadline)
                
            }
            
        } else {
            
            _Title(title)
            
        }
        
    }
    
}

struct Title_Previews: PreviewProvider {
    static var previews: some View {
        Title("Hear Birds Again")
    }
}
