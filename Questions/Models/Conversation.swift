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

class Conversation: PFObject, PFSubclassing {
    
    private lazy var __once: () = {
            // inform Parse about this subclass
            self.registerSubclass()
        }()
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toUser: PFUser?
    
    class func parseClassName() -> String {
        return "Conversation"
    }
    
    override class func initialize() {
        var onceToken: Int = 0;
        _ = self.__once
    }
}
