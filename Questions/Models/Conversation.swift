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

class Conversation: PFObject, PFSubclassing {
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toUser: PFUser?
    
    class func parseClassName() -> String {
        return "Conversation"
    }
}
