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
            
            VStack {
                
                Text("Hear Birds Again")
                    .font(.system(size: 35, weight: .bold, design: .default))
                
                Text("v\(getAppVersion())")
                    .font(.subheadline)
                
            }
            .padding(50)
            
            Spacer()
            
            Text("Help is on the way!")

            Spacer()
            
        }
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
