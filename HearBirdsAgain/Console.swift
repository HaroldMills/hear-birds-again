//
//  Console.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 5/25/22.
//

import Foundation


class Console: ObservableObject {
    
    @Published var text = ""

    func log(_ newText: String = "") {
        text += newText + "\n"
    }
    
}


// The one and only Console of this app.
let console = Console()
