//
//  HelpView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

let helpUrl = Bundle.main.url(forResource: "Help", withExtension: "html")

struct HelpView: View {
    
    var body: some View {
        
        VStack {
            
            Title("Help")
                .padding()
            
            WebView(url: helpUrl!)
                .frame(width: 300, height: 450)
                .background(.clear)
            
        }
        .hbaScrollbar()
        .hbaBackground()
        
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
