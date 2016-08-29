//
//  BlockHelper.swift
//  Questions
//
//  Created by Roland Shen on 8/20/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import Parse

class BlockHelper {
    
    static func getBlockedUsers() -> [PFUser] {
        var blockedUsers: [PFUser] = []
        let query = Block.query()!
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if(error == nil) {
                let blocks = objects as? [Block]
                for block in blocks! {
                    blockedUsers.append(block.toUser!)
                }
            }
        }
        return blockedUsers
    }
}