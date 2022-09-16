//
//  ViewExtensions.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//


import Foundation
import SwiftUI


private struct HbaScrollbarModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        
        // We use an HStack here to ensure that the ScrollView
        // will span the entire width of the display, even if
        // the content does not.
        ScrollView(.vertical) {
            HStack {
                Spacer()
                content
                Spacer()
            }
        }
        
    }
    
}


private struct HbaBackgroundModifier: ViewModifier {

    func body(content: Content) -> some View {
        
        content
        .background(
            Image("BlackAndWhiteWarbler")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.15),
            alignment: .top)
        
    }
    
}


extension View {
    
    func hbaScrollbar() -> some View {
        modifier(HbaScrollbarModifier())
    }
    
    func hbaBackground() -> some View {
        modifier(HbaBackgroundModifier())
    }
    
}
