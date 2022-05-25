//
//  Errors.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 5/25/22.
//

import Foundation


// TODO: Notify development team of errors, perhaps using something like Firebase Crashlytics.


class Errors: ObservableObject {
    
    
    @Published var nonfatalErrorOccurred = false
    
    @Published var nonfatalErrorMessage = ""
    
    @Published var fatalErrorOccurred = false
    
    @Published var fatalErrorMessage = ""
    
    
    func handleNonfatalError(message: String) {
        nonfatalErrorMessage = message
        nonfatalErrorOccurred = true
    }
    
    
    func handleFatalError(message: String) {
        fatalErrorMessage = message
        fatalErrorOccurred = true
    }
    
    
}


// The one and only Errors object of this app.
var errors = Errors()
