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
    
    static func getNumLikes(_ object: PFObject) -> Int {
        let question = object as! Question
        var count = 0
        
        let query = PFQuery(className: "Like")
        query.includeKey("toPost")
        query.whereKey("toPost", equalTo: question)
        query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                count = (objects?.count)!
            }
        }
        return count
    }

    static func getNumLikesAsync(_ object: PFObject, completionHandler: @escaping (Int) -> Void) {
        let question = object as! Question
        
        let query = PFQuery(className: "Like")
        query.includeKey("toPost")
        query.whereKey("toPost", equalTo: question)
        query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    static func likesForPost(_ post: Question, completionBlock: @escaping PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Like")
        query.whereKey("toPost", equalTo: post)
        query.includeKey("toPost")
        query.findObjectsInBackground(block: completionBlock)
    }
    
    static func likePost(_ user: PFUser, question: Question) {
        let likeObject = Like()
        likeObject.fromUser = user
        likeObject.toPost = question
        likeObject.saveInBackground(block: nil)
    }
    
    static func unlikePost(_ user: PFUser, question: Question) {
        let query = PFQuery(className: "Like")
        query.whereKey("fromUser", equalTo: user)
        query.whereKey("toPost", equalTo: question)
        
        query.findObjectsInBackground { (results: [PFObject]?, error: NSError?) -> Void in
            if let results = results {
                for like in results {
                    like.deleteInBackground(block: nil)
                }
            }
        }
    }
}
