//
//  Profile.swift
//  Questions
//
//  Created by Roland Shen on 8/10/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import Parse

class User: PFObject, PFSubclassing {
    
    @NSManaged var bio: String?
    @NSManaged var profilePic: PFFile?
    
    class func parseClassName() -> String {
        return "User"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}