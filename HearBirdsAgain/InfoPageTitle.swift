//
//  InfoPageTitle.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/14/22.
//

import SwiftUI

struct InfoPageTitle: View {
    
    // `title` is of type `LocalizedStringKey` to support Markdown.
    // See https://www.hackingwithswift.com/quick-start/swiftui/how-to-render-markdown-content-in-text
    // for more on this.
    var title: LocalizedStringKey
    
    init(_ title: LocalizedStringKey) {
        self.title = title
    }
    
    var body: some View {
        
        Text(title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(HbaView.titleColor)
            .padding([.top], 35)
            .padding([.leading])
        
    }
    
}

struct InfoPageTitle_Previews: PreviewProvider {
    static var previews: some View {
        InfoPageTitle("Info")
    }
}
