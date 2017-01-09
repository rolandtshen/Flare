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
import ChameleonFramework
import Bond

class QuestionCell: PFTableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryFlag: UIView!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var post: Question? {
        didSet {
            likeDisposable?.dispose()
            if let post = post {
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    if let value = value {
                        self.likesLabel.text = "\(LikeHelper.getNumLikes(post))"
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        if value.count == 0 {
                            self.likeButton.setImage(UIImage(named: "like"), forState: .Normal)
                        } else {
                            self.likeButton.setImage(UIImage(named: "liked"), forState: .Normal)
                        }
                    } else {
                        self.likesLabel.text = "\(LikeHelper.getNumLikes(post))"
                        self.likeButton.selected = false
                        self.likeButton.setImage(UIImage(named: "like"), forState: .Normal)
                    }
                }
            }
        }
    }

    var numberOfLikes : Int!
    
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    @IBAction func likePressed(sender: AnyObject) {
        post!.toggleLikePost(PFUser.currentUser()!)
    }
}