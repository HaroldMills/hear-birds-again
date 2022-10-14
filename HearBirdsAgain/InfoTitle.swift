//
//  InfoTitle.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/14/22.
//

import SwiftUI

struct InfoTitle: View {
    
    var title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        
        Text(title)
            .font(.title)
            .fontWeight(.bold)
            .padding([.leading, .top])
        
    }
    
}

struct InfoTitle_Previews: PreviewProvider {
    static var previews: some View {
        InfoTitle("Info")
    }
}
