//
//  Logger.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 5/25/22.
//

import Foundation


class Logger: ObservableObject {
    
    @Published var logText = ""

    func log(_ text: String = "") {
        logText += text + "\n"
    }
    
}


// The one and only Logger of this app.
let logger = Logger()
