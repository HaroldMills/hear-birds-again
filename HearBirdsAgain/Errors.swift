//
//  Errors.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 5/25/22.
//

import Foundation


class Errors: ObservableObject {
    
    @Published var nonfatalErrorOccurred = false
    
    @Published var nonfatalErrorMessage = ""
    
    @Published var fatalErrorOccurred = false
    
    @Published var fatalErrorMessage = ""
    
}


var errors = Errors()
