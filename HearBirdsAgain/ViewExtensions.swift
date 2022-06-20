//
//  ViewExtensions.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//


import Foundation
import SwiftUI


private struct HbaBackgroundModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(
                Image("BlackAndWhiteWarbler")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.15))
    }
    
}


extension View {
    func hbaBackground() -> some View {
        modifier(HbaBackgroundModifier())
    }
}
