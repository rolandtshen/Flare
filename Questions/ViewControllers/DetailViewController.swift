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
import SCLAlertView

class DetailViewController: PFQueryTableViewController {
   
    var question: Question?
    var numReplies: Int?
    var questionHeaderView: QuestionHeaderView?
    var questionImageHeaderView: QuestionImageHeaderView?
    let colorPicker = CategoryHelper()
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if question!.hasImage == true {
            questionImageHeaderView = UINib(nibName: "QuestionHeaderImageView", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first as? QuestionImageHeaderView
            questionImageHeaderView?.poster = question?.user
            questionImageHeaderView?.questionLabel.text = question?.question
            questionImageHeaderView?.timeLabel.text = question?.createdAt?.shortTimeAgoSinceDate(NSDate())
            questionImageHeaderView?.usernameLabel.text = question!.user?.username
            questionImageHeaderView?.imageView.clipsToBounds = true
            questionImageHeaderView?.categoryView.backgroundColor = colorPicker.colorChooser(question!.category!)
            getImage(question!, completionHandler: {(image) in
                self.questionImageHeaderView?.imageView.image = image
            })
        } else {
            questionHeaderView = UINib(nibName: "QuestionHeaderView", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first as? QuestionHeaderView
            questionHeaderView?.poster = question?.user
            questionHeaderView?.questionLabel.text = question?.question
            questionHeaderView?.timeLabel.text = question?.createdAt?.shortTimeAgoSinceDate(NSDate())
            questionHeaderView?.usernameLabel.text = question!.user?.username
            questionHeaderView?.categoryView.backgroundColor = colorPicker.colorChooser(question!.category!)
        }
        
        //self.tableView.tableHeaderView = questionHeaderView ?? questionImageHeaderView
        
    }
    
    func getImage(object: PFObject, completionHandler: (UIImage) -> Void) {
        let question = object as! Question
        if let picture = question.imageFile {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    func getProfilePic(user: PFUser, completionHandler: (UIImage) -> Void) {
        let profile = user
        if let picture = profile.objectForKey("profilePic") {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (imageData != nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Reply")
        query.whereKey("toPost", equalTo: question!)
        query.limit = 100;
        query.orderByAscending("createdAt")
        query.includeKey("fromUser")
        return query
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(questionHeaderView != nil) {
            return questionHeaderView
        }
        return questionImageHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(questionHeaderView != nil) {
            return 200.0
        }
        return 315.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("replyCell", forIndexPath: indexPath) as! ReplyCell
        cell.postTime.text = object!.createdAt?.shortTimeAgoSinceDate(NSDate())
        cell.replyText.text = object!.valueForKey("reply") as? String
        let user = object!.valueForKey("fromUser") as? PFUser
        cell.usernameLabel.text = user?.username
        getProfilePic((user)!) { (image) in
            cell.replyProfilePic.image = image
        }
        return cell
    }
}