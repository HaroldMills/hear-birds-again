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
            
            Spacer()
            
            Text("Hear Birds Again")
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding()
            
            Text("Help is on the way!")
                .padding()
            
            Spacer()
            
        }
        .background(
            Image("BlackAndWhiteWarbler")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.15))
        
    }
    
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
