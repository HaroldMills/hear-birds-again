//
//  InfoPageSectionHeader.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/17/22.
//

import SwiftUI

let defaultColor = hexToColor(0x8a4e38)

struct InfoPageSectionHeader: View {
    
    // `header` is of type `LocalizedStringKey` to support Markdown.
    // See https://www.hackingwithswift.com/quick-start/swiftui/how-to-render-markdown-content-in-text
    // for more on this.
    var header: LocalizedStringKey
    var color: Color
    
    init(_ header: LocalizedStringKey, color: Color = defaultColor) {
        self.header = header
        self.color = color
    }
    
    var body: some View {
        
        Text(header)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(color)
            .padding([.leading, .top, .trailing])
        
    }
    
}

struct InfoPageSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        InfoPageSectionHeader("Header")
    }
}

func hexToColor(_ hex: UInt) -> Color {
    let mask: UInt = 0xff
    let red = Double((hex >> 16) & mask) / 255
    let green = Double((hex >> 8) & mask) / 255
    let blue = Double(hex & mask) / 255
    return Color(red: red, green: green, blue: blue)
}
