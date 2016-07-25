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
    
    @IBOutlet weak var replyText: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var replyProfilePic: UIImageView!
    
    var reply: Reply? {
        didSet {
            if reply != nil {
                self.postTime.text = reply?.createdAt?.shortTimeAgoSinceDate(NSDate())
                self.replyText.text = reply?.reply
                self.usernameLabel.text = reply!.fromUser?.username
            }
        }
    }
}

