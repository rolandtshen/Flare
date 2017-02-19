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
    
    private lazy var __once: () = {
            // inform Parse about this subclass
            self.registerSubclass()
        }()
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toPost: PFObject?
    
    class func parseClassName() -> String {
        return "Like"
    }
    
    override class func initialize() {
        var onceToken: Int = 0;
        _ = self.__once
    }
}
