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
    
    private lazy var __once: () = {
            // inform Parse about this subclass
            self.registerSubclass()
        }()
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toPost: PFObject?
    
    class func parseClassName() -> String {
        return "Flag"
    }
    
    override class func initialize() {
        var onceToken: Int = 0;
        _ = self.__once
    }
}
