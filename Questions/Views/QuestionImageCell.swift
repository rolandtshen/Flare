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
import ReactiveKit

class QuestionImageCell: PFTableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var categoryFlag: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    var likeDisposable: Disposable?
    
    var post: Question? {
        didSet {
            likeDisposable?.dispose()
            if let post = post {
                likeDisposable = post.likes.observe { (value) in
                    print(value)
//                    if let value = value {
//                        self.likesLabel.text = self.numLikes(value)
//                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
//                        if value.count == 0 {
//                            self.likeButton.setImage(UIImage(named: "like"), for: .normal)
//                        } else {
//                            self.likeButton.setImage(UIImage(named: "liked"), for: .normal)
//                        }
//                    } else {
//                        self.likesLabel.text = "\(LikeHelper.getNumLikes(post))"
//                        self.likeButton.isSelected = false
//                        self.likeButton.setImage(UIImage(named: "like"), for: .normal)
//                    }
                }
            }
        }
    }
    
    func numLikes(_ userList: [PFUser]) -> String {
        let likes = userList.count
        let stringLikes = String(likes)
        return stringLikes
    }
    
    @IBAction func likePressed(_ sender: AnyObject) {
        post!.toggleLikePost(PFUser.current()!)
    }
}
