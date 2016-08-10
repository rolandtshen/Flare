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
    
//    static func likePost(user: PFUser?, post: Question) {
//        let likeObject = PFObject(className: "Like")
//        likeObject["fromUser"] = user
//        likeObject["toPost"] = post
//        likeObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
//    }
//    
//    static func unlikePost(user: PFUser, post: Question) {
//        let query = PFQuery(className: "Like")
//        query.whereKey("fromUser", equalTo: user)
//        query.whereKey("toPost", equalTo: post)
//        
//        query.findObjectsInBackgroundWithBlock {(results: [PFObject]?, error: NSError?) -> Void in
//            if let results = results {
//                for like in results {
//                    like.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
//                }
//            }
//        }
//    }
//    
//    static func doesUserLikePost(user: PFUser, post: Question) -> Bool {
//        var flag: Bool?
//        let query = PFQuery(className: "Like")
//        query.whereKey("fromUser", equalTo: user)
//        query.whereKey("toPost", equalTo: post)
//        query.findObjectsInBackgroundWithBlock {(results: [PFObject]?, error: NSError?) -> Void in
//            if (results != nil) {
//                flag = true
//            }
//            else {
//                flag = false
//            }
//        }
//        return flag!
//    }
//    
    static func toggleLikePost(user: PFUser, post: Question, completionHandler: (isLiked:Bool) -> Void) {
//        if (doesUserLikePost(user, post: post)) {
//            // if post is liked, unlike it now
//            unlikePost(user, post: post)
//        } else {
//            // if this post is not liked yet, like it now
//            likePost(user, post: post)
//        }
        let query = PFQuery(className: "Like")
        query.whereKey("fromUser", equalTo: user)
        query.whereKey("toPost", equalTo: post)
        query.findObjectsInBackgroundWithBlock {(results: [PFObject]?, error: NSError?) -> Void in
            if (results!.count != 0) {
                //flag = true, and let's unlike
                let query = PFQuery(className: "Like")
                query.whereKey("fromUser", equalTo: user)
                query.whereKey("toPost", equalTo: post)
                
                query.findObjectsInBackgroundWithBlock {(results: [PFObject]?, error: NSError?) -> Void in
                    if let results = results {
                        for like in results {
                            like.deleteInBackgroundWithBlock({ (bool:Bool, error:NSError?) in
                                completionHandler(isLiked: true)
                            })
                        }
                    }
                }
            }
            else {
                //flag = false,let's like
                let likeObject = PFObject(className: "Like")
                likeObject["fromUser"] = user
                likeObject["toPost"] = post
                likeObject.saveInBackgroundWithBlock({ (bool:Bool, error:NSError?) in
                    completionHandler(isLiked: false)
                })
            }
        }
    }
}