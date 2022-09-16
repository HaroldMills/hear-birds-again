//
//  HelpView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

struct HelpView: View {
    
    var body: some View {
        
        VStack {
            
            Title(subtitle: "Version \(getAppVersion())")
                .padding()
            
            Spacer()
            
            Text("Help is on the way!")

            Spacer()
            
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
