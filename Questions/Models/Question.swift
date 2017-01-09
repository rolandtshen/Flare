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
import Bond

class Question: PFObject, PFSubclassing {
   
    @NSManaged var user: PFUser?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var category: String?
    @NSManaged var question: String?
    @NSManaged var imageFile: PFFile?
    @NSManaged var hasImage: Bool
    //@NSManaged var likes: NSNumber?

    var likes: Observable<[PFUser]?> = Observable(nil)
    
    class func parseClassName() -> String {
        return "Post"
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if post is liked, unlike it now
            likes.value = likes.value?.filter { $0 != user }
            LikeHelper.unlikePost(user, question: self)
        } else {
            // if this post is not liked yet, like it now
            likes.value?.append(user)
            LikeHelper.likePost(user, question: self)
        }
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func fetchLikes() {
        if (likes.value != nil) {
            return
        }
        
        LikeHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            let validLikes = likes?.filter { like in like["fromUser"] != nil }
            
            self.likes.value = validLikes?.map { like in
                let fromUser = like["fromUser"] as! PFUser
                
                return fromUser
            }
        })
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}