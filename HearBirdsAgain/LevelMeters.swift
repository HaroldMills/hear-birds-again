//
//  LevelMeters.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/5/22.
//

import SwiftUI

struct LevelMeters: View {
    
    @ObservedObject var audioProcessor: AudioProcessor
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<$audioProcessor.outputLevels.count, id: \.self) { i in
                LevelMeter(level: $audioProcessor.outputLevels[i])
            }
        }
    }
}

struct LevelMeters_Previews: PreviewProvider {
    static var previews: some View {
        LevelMeters(audioProcessor: audioProcessor)
    }
}
