//
//  ReplyCell.swift
//  Questions
//
//  Created by Roland Shen on 7/12/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import ParseUI

class ReplyCell: PFTableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var replyText: UILabel!
    @IBOutlet weak var postTime: UILabel!
}

