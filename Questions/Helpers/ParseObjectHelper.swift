//
//  ParseObjectHelper.swift
//  Questions
//
//  Created by Roland Shen on 8/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import Parse

extension PFObject {
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
    
}