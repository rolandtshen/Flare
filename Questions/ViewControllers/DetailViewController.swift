//
//  DetailViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/13/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class DetailViewController: PFQueryTableViewController {
   
    var question: Question?
    var numReplies: Int?
    var questionHeaderView: QuestionHeaderView?
    var questionImageHeaderView: QuestionImageHeaderView?
    let colorPicker = CategoryHelper()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if question!.hasImage == true {
            questionImageHeaderView = UINib(nibName: "QuestionHeaderImageView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? QuestionImageHeaderView
            questionImageHeaderView?.poster = question?.user
            questionImageHeaderView?.questionLabel.text = question?.question
            questionImageHeaderView?.timeLabel.text = (question?.createdAt as NSDate?)?.shortTimeAgo(since: Date())
            questionImageHeaderView?.usernameLabel.text = question!.user?.username
            questionImageHeaderView?.imageView.clipsToBounds = true
            questionImageHeaderView?.categoryView.backgroundColor = colorPicker.colorChooser(question!.category!)
            getImage(question!, completionHandler: {(image) in
                self.questionImageHeaderView?.imageView.image = image
            })
        } else {
            questionHeaderView = UINib(nibName: "QuestionHeaderView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? QuestionHeaderView
            questionHeaderView?.poster = question?.user
            questionHeaderView?.questionLabel.text = question?.question
            questionHeaderView?.timeLabel.text = (question?.createdAt as NSDate?)?.shortTimeAgo(since: Date())
            questionHeaderView?.usernameLabel.text = question!.user?.username
            questionHeaderView?.categoryView.backgroundColor = colorPicker.colorChooser(question!.category!)
        }
        
        //self.tableView.tableHeaderView = questionHeaderView ?? questionImageHeaderView
        
    }
    
    func getImage(_ object: PFObject, completionHandler: @escaping (UIImage) -> Void) {
        let question = object as! Question
        if let picture = question.imageFile {
            picture.getDataInBackground(block: {
                (imageData, error) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    func getProfilePic(_ user: PFUser, completionHandler: @escaping (UIImage) -> Void) {
        let profile = user
        if let picture = profile.object(forKey: "profilePic") {
            (picture as AnyObject).getDataInBackground(block: {
                (imageData, error) -> Void in
                if (imageData != nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: "Reply")
        query.whereKey("toPost", equalTo: question!)
        query.limit = 100;
        query.order(byAscending: "createdAt")
        query.includeKey("fromUser")
        return query
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(questionHeaderView != nil) {
            return questionHeaderView
        }
        return questionImageHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(questionHeaderView != nil) {
            return 200.0
        }
        return 315.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! ReplyCell
        cell.postTime.text = (object!.createdAt as NSDate?)?.shortTimeAgo(since: Date())
        cell.replyText.text = object!.value(forKey: "reply") as? String
        let user = object!.value(forKey: "fromUser") as? PFUser
        cell.usernameLabel.text = user?.username
        getProfilePic((user)!) { (image) in
            cell.replyProfilePic.image = image
        }
        return cell
    }
}
