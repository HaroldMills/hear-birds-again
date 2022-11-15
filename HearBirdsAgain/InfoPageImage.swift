//
//  InfoPageImage.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 11/14/22.
//

import SwiftUI

struct InfoPageImage: View {
    
    var name: String
    var caption: String?
    
    init(_ name: String, caption: String? = nil) {
        self.name = name
        self.caption = caption
    }
    
    var body: some View {
        
        if caption == nil {
            
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        } else {
            
            VStack(alignment: .leading) {
                
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text(caption!)
                    .font(.caption)
                
            }
            
        }
                
    }

}

struct InfoPageImage_Previews: PreviewProvider {
    static var previews: some View {
        InfoPageImage("")
    }
}
