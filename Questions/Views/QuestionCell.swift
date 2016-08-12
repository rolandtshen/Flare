//
//  QuestionCell.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import ParseUI
import Parse

class QuestionCell: PFTableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryFlag: UIView!
    @IBOutlet weak var likesLabel: UIButton!
    @IBOutlet weak var profilePicView: UIImageView!
    
    var post : Question!
    var numberOfLikes : Int!
    
    @IBAction func likePressed(sender: AnyObject) {
        LikeHelper.toggleLikePost(PFUser.currentUser()!, post: post) { (isLiked) in
            
            if isLiked {
                self.likesLabel.titleLabel?.text = "♥️ Likes (\(self.numberOfLikes - 1))"
                self.numberOfLikes = self.numberOfLikes - 1
            } else {
                self.likesLabel.titleLabel?.text = "♥️ Likes (\(self.numberOfLikes + 1))"
                self.numberOfLikes = self.numberOfLikes + 1
            }
        }
    }
}