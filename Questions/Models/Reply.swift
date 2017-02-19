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

class Reply: PFObject, PFSubclassing {
    
    private lazy var __once: () = {
            // inform Parse about this subclass
            self.registerSubclass()
        }()
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var reply: String?
    @NSManaged var imageFile: PFFile
    @NSManaged var toPost: PFObject?
    @NSManaged var username: String?
    
    class func parseClassName() -> String {
        return "Reply"
    }
    
    override class func initialize() {
        var onceToken: Int = 0;
        _ = self.__once
    }
}
