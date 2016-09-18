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
    
    func doesUserLikePost(question: Question) -> Bool {
        let query = Like.query()
        var flag = false
        query?.whereKey("toPost", equalTo: question)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) in
            if error == nil {
                let likes = objects as! [Like]
                for like in likes {
                    if like.fromUser == PFUser.currentUser() {
                        flag = true
                    }
                }
            }
        })
        return flag
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}