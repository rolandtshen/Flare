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
    
    private lazy var __once: () = {
            self.registerSubclass()
        }()
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toUser: PFUser?
    
    class func parseClassName() -> String {
        return "Block"
    }
    
    override class func initialize() {
        var onceToken: Int = 0;
        _ = self.__once
    }
}
