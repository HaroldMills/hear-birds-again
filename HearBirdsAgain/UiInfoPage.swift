//
//  UiInfoPage.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 10/17/22.
//

import SwiftUI

struct UiInfoPage: View {
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading) {
                
                InfoPageTitle("The User Interface")
    
                Text("""
The ***Hear Birds Again*** user interface comprises three tabs, named *Listen*, *More Controls*, and *Info*. Only one tab is visible at a time, according to the icon selected in the *tab bar* at the bottom of the screen. You are currently viewing the *Info* tab. To see either of the other tabs, just tap its icon in the tab bar.
""")
                .padding()

                Group {
                    
                    InfoPageSectionHeader("The *Listen* Tab")
                    
                    Text("""
    You'll probably use the *Listen* tab most often, since it includes the primary app controls. These include the controls that allow you to adjust the amount of pitch shifting the app performs and the frequency at which shifting starts.
    
    The *Listen* tab looks like this:
    """)
                    .padding()
                    
                    Image("ListenTab")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.leading, .bottom, .trailing])

                    Text("""
    Throughout the user interface, most controls are accompanied by a small help button that looks like this:
    """)
                    .padding()
                    
                    HStack {
                        
                        Spacer()
                        
                        Image("HelpButton")
                            .resizable()
                            .frame(width: 32, height: 30
                            )
                        // .aspectRatio(contentMode: .fit)
                            .padding([.leading, .trailing])
                        
                        Spacer()
                        
                    }
                    
                    Text("""
    You can tap a control's help button to see a detailed explanation of the control's function. So, for example, you can tap the help buttons for the *Pitch Shift* and *Start Frequency* controls on the *Listen* tab to learn more about them.
    """)
                    .padding()
                    
                }
                
                Group {
                    
                    InfoPageSectionHeader("The *More Controls* Tab")
                    
                    Text("""
    The *More Controls* tab includes less-frequently used controls. These controls allow you to adjust the gain (that is, amplification) and balance (when the output is stereo) for the current input device (for example, the R0DE AI-Micro if you're using the recommended binaural headset, or the iPhone Microphone in many other cases). For many input devices, these controls will require no adjustment. For others, you may want to adjust them when you first start using a device, but once you have adjusted them appropriately you will probably not need to adjust them again.
    
    The *More Controls* tab looks like this:
    """)
                    .padding()
                    
                    Image("MoreControlsTab")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.leading, .bottom, .trailing])
                    
                }
                
                Group {
                    
                    InfoPageSectionHeader("The *Info* Tab")
                    
                    Text("""
The *Info* tab includes several pages of documentation for the app. You can navigate among the pages by swiping left and right or tapping to the left or right of the row of dots near the bottom of the screen.
""")
                    .padding()
                    
                }
                
            }
            .hbaScrollbar()
            
            Rectangle()
                .frame(height: 45)
                .foregroundColor(.clear)
            
        }
        .hbaBackground()
        
    }
    
}

struct UiInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        UiInfoPage()
    }
}
