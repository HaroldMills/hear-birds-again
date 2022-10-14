//
//  HelpDoneButton.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/14/22.
//

import SwiftUI

// Done button for dismissing help views.
struct HelpDoneButton: View {
    
    @Binding var isPresented: Bool

    var body: some View {
        
        HStack {
            
            Spacer()
            
            Button("Done") {
                isPresented = false
            }
            
        }
        .padding([.leading, .top, .trailing])
        
    }
    
}

struct HelpDoneButton_Previews: PreviewProvider {
    static var previews: some View {
        HelpDoneButton(isPresented: .constant(true))
    }
}
