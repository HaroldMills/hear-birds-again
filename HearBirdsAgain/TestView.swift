//
//  TestView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/20/22.
//

import SwiftUI

struct TestView: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text("Hear Birds Again")
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding()
            
            HStack {
                
                Text("Window:")
                
                Picker("Window", selection: $audioProcessor.windowType) {
                    Text("Hann").tag(WindowType.Hann)
                    Text("SongFinder").tag(WindowType.SongFinder)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                
            }
            .padding()
            
            VStack {

                Text("Window Size (ms):")
                
                Picker("Window Size", selection: $audioProcessor.windowSize) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                    Text("15").tag(15)
                    Text("20").tag(20)
                    Text("25").tag(25)
                    Text("30").tag(30)
                    Text("35").tag(35)
                    Text("40").tag(40)
                    Text("45").tag(45)
                    Text("50").tag(50)
                }
                .pickerStyle(.segmented)
                .fixedSize()

            }
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

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(audioProcessor: audioProcessor)
    }
}
