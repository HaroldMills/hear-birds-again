//
//  InfoPageSectionHeader.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/17/22.
//

import SwiftUI

struct InfoPageSectionHeader: View {
    
    // `header` is of type `LocalizedStringKey` to support Markdown.
    // See https://www.hackingwithswift.com/quick-start/swiftui/how-to-render-markdown-content-in-text
    // for more on this.
    var header: LocalizedStringKey
    
    init(_ header: LocalizedStringKey) {
        self.header = header
    }
    
    var body: some View {
        
        Text(header)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(HbaView.titleColor)
            .padding([.leading, .top, .trailing])
        
    }
    
}

struct InfoPageSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        InfoPageSectionHeader("Header")
    }
}
