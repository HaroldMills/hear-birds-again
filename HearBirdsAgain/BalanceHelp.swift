//
//  BalanceHelp.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/3/22.
//

import SwiftUI

struct BalanceHelp: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HelpTitle("Balance")
            
            Spacer()
            
            Text(
                "Use the *Balance* control to adjust the relative volume of the left and right channels of stereo output. When the balance is positive the right channel is louder than the left one, and when it is negative the left channel is louder than the right one.")
            .padding()
            
            Spacer()
            
        }
        .hbaHelp(isPresented: $isPresented)
        
    }
    
}

struct BalanceHelp_Previews: PreviewProvider {
    static var previews: some View {
        BalanceHelp(isPresented: .constant(true))
    }
}
