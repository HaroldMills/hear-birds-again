//
//  HelpTitle.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/14/22.
//

import SwiftUI

struct HelpTitle: View {
    
    var title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        
        HStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }
        .padding([.leading, .trailing])
        
    }
    
}

struct HelpTitle_Previews: PreviewProvider {
    static var previews: some View {
        HelpTitle("Help")
    }
}
