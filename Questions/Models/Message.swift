//
//  Message.swift
//  Questions
//
//  Created by Roland Shen on 7/26/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Message: PFObject, PFSubclassing {
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var text: String?
    @NSManaged var attachment: PFFile?
    
    class func parseClassName() -> String {
        return "Message"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }

}