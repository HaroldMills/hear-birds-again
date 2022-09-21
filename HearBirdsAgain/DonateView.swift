//
//  DonateView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/21/22.
//

import SwiftUI

struct DonateView: View {
    
    var body: some View {
        
        VStack {
            
            Title("Donate")
                .padding()
            
            Spacer()

            Text(
                "If you find Hear Birds Again useful, please [donate](https://hearbirdsagain.org/donate/) to support its continued development and maintenance.")
                            
            Spacer()
            
        }
        .hbaScrollbar()
        .hbaBackground()
        
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
