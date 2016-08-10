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

    static func toggleLikePost(user: PFUser, post: Question, completionHandler: (isLiked:Bool) -> Void) {
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
                likeObject.saveInBackgroundWithBlock({ (bool: Bool, error: NSError?) in
                    completionHandler(isLiked: false)
                })
            }
        }
    }
}