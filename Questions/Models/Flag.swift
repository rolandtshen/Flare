//
//  Flag.swift
//  Questions
//
//  Created by Roland Shen on 8/10/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import Parse

class Flag: PFObject, PFSubclassing {
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toPost: PFObject?
    
    class func parseClassName() -> String {
        return "Flag"
    }
    
    override class func initialize() {
        self.registerSubclass()
    }
}
