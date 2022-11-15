//
//  ViewExtensions.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//


import Foundation
import SwiftUI


private struct HbaHelpModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        
        VStack {
            
            HelpDoneButton(isPresented: $isPresented)
            
            content
                .hbaScrollbar()
            
        }
        .hbaBackground()
        
    }
    
}


private struct HbaScrollbarModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        
        // We use an `HStack` here to ensure that the `ScrollView`
        // will span the entire width of the display, even if
        // `content` does not.
        ScrollView(.vertical) {
            HStack {
                Spacer()
                content
                    .frame(maxWidth: 500)
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


private struct HbaScreenshotModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 390)
    }
    
}


extension View {
    
    func hbaHelp(isPresented: Binding<Bool>) -> some View {
        modifier(HbaHelpModifier(isPresented: isPresented))
    }
    
    func hbaScrollbar() -> some View {
        modifier(HbaScrollbarModifier())
    }
    
    func hbaBackground() -> some View {
        modifier(HbaBackgroundModifier())
    }
    
    func hbaScreenshot() -> some View {
        modifier(HbaScreenshotModifier())
    }
    
}
