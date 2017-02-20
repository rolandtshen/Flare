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

class Reply: PFObject, PFSubclassing {
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var reply: String?
    @NSManaged var imageFile: PFFile
    @NSManaged var toPost: PFObject?
    @NSManaged var username: String?
    
    class func parseClassName() -> String {
        return "Reply"
    }
}
