//
//  Block.swift
//  Questions
//
//  Created by Roland Shen on 8/20/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation

class Block: PFObject, PFSubclassing {
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toUser: PFUser?
    
    class func parseClassName() -> String {
        return "Block"
    }
}
