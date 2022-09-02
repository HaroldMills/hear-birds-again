//
//  LevelMeter.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 6/29/22.
//

import SwiftUI

struct LevelMeter: View {
    
    @Binding var level: Float
    var minLevel: Float = -80
    var maxLevel: Float = 0
    var minYellowLevel: Float = -20
    var minRedLevel: Float = -10
    var segmentSize: Float = 5

    let meterWidth: CGFloat = 250
    let segmentSpacing: CGFloat = 2.0

    var segmentCount: Int {
        return Int(round((maxLevel - minLevel) / segmentSize))
    }
    
    // Segment width in pixels.
    var segmentWidth: CGFloat {
        let totalSpacing = CGFloat(segmentCount - 1) * segmentSpacing
        return (meterWidth - totalSpacing) / CGFloat(segmentCount)
    }
    
    var body: some View {
        
        HStack(spacing: segmentSpacing) {
            
            ForEach(0..<segmentCount, id: \.self) { i in
                let startLevel = getStartLevel(i)
                let color = getColor(startLevel)
                _MeterSegment(
                    level: $level,
                    startLevel: startLevel,
                    endLevel: startLevel + segmentSize,
                    width: segmentWidth,
                    color: color)
            }
            
        }

    }
    
    func getStartLevel(_ i: Int) -> Float {
        return Float(i - segmentCount) * segmentSize
    }
    
    func getColor(_ startLevel: Float) -> Color {
        if startLevel < minYellowLevel {
            return .green
        } else if startLevel < minRedLevel {
            return .yellow
        } else {
            return .red
        }
    }
    
}

struct _MeterSegment: View {
    
    @Binding var level: Float
    var startLevel: Float
    var endLevel: Float
    var width: CGFloat
    var color: Color
    
    var body: some View {
        
        Rectangle()
            .fill(getColor())
            .frame(width: width, height: 15)
            
    }
    
    func getColor() -> Color {
        if level >= startLevel {
            return color
        } else {
            return color.opacity(0.3)
        }
    }
    
}

struct LevelMeter_Previews: PreviewProvider {
    static var previews: some View {
        LevelMeter(level: .constant(-3))
    }
}
