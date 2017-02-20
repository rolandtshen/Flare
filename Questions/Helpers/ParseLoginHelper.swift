//
//  ParseLoginHelper.swift
//  Makestagram
//
//  Created by Benjamin Encz on 4/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse
import ParseUI

typealias ParseLoginHelperCallback = (PFUser?, Error?) -> Void

/**
 This class implements the 'PFLogInViewControllerDelegate' protocol. After a successfull login
 it will call the callback function and provide a 'PFUser' object.
 */
class ParseLoginHelper : NSObject {
    static let errorDomain = "com.makeschool.parseloginhelpererrordomain"
    static let usernameNotFoundErrorCode = 1
    static let usernameNotFoundLocalizedDescription = "Could not retrieve Facebook username"
    
    let callback: ParseLoginHelperCallback
    
    init(callback: @escaping ParseLoginHelperCallback) {
        self.callback = callback
    }
}

extension ParseLoginHelper : PFSignUpViewControllerDelegate {
    
    func signUpViewController(_ signUpController: PFSignUpViewController, didSignUp user: PFUser) {
        self.callback(user, nil)
    }
}
