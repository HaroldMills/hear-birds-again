//
//  AboutView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/21/22.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        
        VStack {
            
            Title("About")
                .padding()
                  
            Spacer()
                  
            Text("Version \(getAppVersion())")
                 
            Spacer()
                        
        }
        .hbaScrollbar()
        .hbaBackground()
        
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
