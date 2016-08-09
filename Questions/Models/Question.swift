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

class Question: PFObject, PFSubclassing {
   
    @NSManaged var user: PFUser?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var category: String?
    @NSManaged var question: String?
    @NSManaged var imageFile: PFFile?
    @NSManaged var hasImage: Bool
    @NSManaged var likes: NSNumber?

    class func parseClassName() -> String {
        return "Post"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}