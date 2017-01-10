//
//  LikeHelper.swift
//  Questions
//
//  Created by Roland Shen on 8/9/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import Parse

class LikeHelper {
    
    static func getNumLikes(object: PFObject) -> Int {
        let question = object as! Question
        var count = 0
        
        let query = PFQuery(className: "Like")
        query.includeKey("toPost")
        query.whereKey("toPost", equalTo: question)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                count = (objects?.count)!
            }
        }
        return count
    }

    static func getNumLikesAsync(object: PFObject, completionHandler: (Int) -> Void) {
        let question = object as! Question
        
        let query = PFQuery(className: "Like")
        query.includeKey("toPost")
        query.whereKey("toPost", equalTo: question)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    static func likesForPost(post: Question, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Like")
        query.whereKey("toPost", equalTo: post)
        query.includeKey("toPost")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func likePost(user: PFUser, question: Question) {
        let likeObject = Like()
        likeObject.fromUser = user
        likeObject.toPost = question
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, question: Question) {
        let query = PFQuery(className: "Like")
        query.whereKey("fromUser", equalTo: user)
        query.whereKey("toPost", equalTo: question)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
}