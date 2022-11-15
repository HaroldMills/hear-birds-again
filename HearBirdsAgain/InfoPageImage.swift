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
    let maxFrameWidth: CGFloat = 500
    
    init(_ name: String, caption: String? = nil) {
        self.name = name
        self.caption = caption
    }
    
    var body: some View {
        
        if caption == nil {
            
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: maxFrameWidth)
            
        } else {
            
            VStack(alignment: .leading) {
                
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text(caption!)
                    .font(.caption)
                
            }
            .frame(maxWidth: maxFrameWidth)
            
        }
                
    }

}

struct InfoPageImage_Previews: PreviewProvider {
    static var previews: some View {
        InfoPageImage("")
    }
}
