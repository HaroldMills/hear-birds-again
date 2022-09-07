//
//  VolumeView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/7/22.
//

import MediaPlayer
import SwiftUI
import UIKit

struct VolumeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        MPVolumeView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
    }
    
}
