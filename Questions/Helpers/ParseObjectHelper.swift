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
        guard let object = object as? PFObject else { return false }
        return object.objectId == self.objectId
    }
}
