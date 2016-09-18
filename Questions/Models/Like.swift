//
//  Question.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation

class Like: PFObject, PFSubclassing {
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toPost: PFObject?
    
    class func parseClassName() -> String {
        return "Like"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}