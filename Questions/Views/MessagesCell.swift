//
//  MessagesCell.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import ParseUI

class MessagesCell: PFTableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var messagePreview: UILabel!
}