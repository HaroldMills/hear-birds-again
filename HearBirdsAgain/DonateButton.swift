//
//  DonateButton.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/7/22.
//


import SwiftUI


// This struct is modeled after an example at
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-open-web-links-in-safari


struct DonateButton: View {
    
    @Environment(\.openURL) var openURL
    
    private let colors: [Color] = [.red, .green, .orange, .blue, .yellow, .purple]
    
    private var buttonColor: Color {
        let index = Int.random(in: 0..<colors.count)
        return colors[index]
    }
    
    var body: some View {
        
        Button {
            openURL(URL(string: "https://hearbirdsagain.org/donate/")!)
        } label: {
            Label("Donate", systemImage: "heart")
        }
        .padding(10)
        .background(buttonColor)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 5))

    }
    
}


struct DonateButton_Previews: PreviewProvider {
    static var previews: some View {
        DonateButton()
    }
}
