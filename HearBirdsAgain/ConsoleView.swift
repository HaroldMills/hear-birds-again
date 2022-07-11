//
//  ConsoleView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

struct ConsoleView: View {
    
    @ObservedObject var console: Console
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                HStack {
                    
                    Text(console.text)
                        .font(Font.system(size: 16).monospaced())
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    
                    Spacer()
                    
                }
                
                Spacer()
                
            }
            
        }
        
    }
    
}

struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleView(console: console)
    }
}
