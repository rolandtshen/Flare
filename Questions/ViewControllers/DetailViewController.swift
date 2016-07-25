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
import IQKeyboardManager

class DetailViewController: PFQueryTableViewController {
   
    var question: Question?
    var numReplies: Int?
    var questionHeaderView: QuestionHeaderView?
    var questionImageHeaderView: QuestionImageHeaderView?

    override func viewDidLoad() {
    
        if question!.hasImage == true {
            questionImageHeaderView = UINib(nibName: "QuestionHeaderImageView", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first as? QuestionImageHeaderView
            questionImageHeaderView?.questionLabel.text = question?.question
            questionImageHeaderView?.timeLabel.text = question?.createdAt?.shortTimeAgoSinceDate(NSDate())
            questionImageHeaderView?.usernameLabel.text = question!.user?.username
            questionImageHeaderView?.imageView.clipsToBounds = true
            getImage(question!, completionHandler: {(image) in
                self.questionImageHeaderView?.imageView.image = image
            })
        }
        else {
            questionHeaderView = UINib(nibName: "QuestionHeaderView", bundle: NSBundle.mainBundle()).instantiateWithOwner(nil, options: nil).first as? QuestionHeaderView
            questionHeaderView?.questionLabel.text = question?.question
            questionHeaderView?.timeLabel.text = question?.createdAt?.shortTimeAgoSinceDate(NSDate())
            questionHeaderView?.usernameLabel.text = question!.user?.username
        }
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
    
    override func queryForTable() -> PFQuery {
        let query = Question.query()!
        ///query.whereKey("toPost", equalTo: question!)
        query.limit = 100;
        query.orderByDescending("createdAt")
        query.includeKey("user")
        return query
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(questionHeaderView != nil) {
            return 125.0
        }
        return 349.0
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(questionHeaderView != nil) {
            return questionHeaderView
        }
        return questionImageHeaderView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let reply = object as! Reply
        let cell = tableView.dequeueReusableCellWithIdentifier("replyCell", forIndexPath: indexPath) as! ReplyCell
        cell.postTime.text = "time"
        cell.replyText.text = "reply"
        cell.usernameLabel.text = "username"
//        cell.postTime.text = reply.createdAt?.shortTimeAgoSinceDate(NSDate())
//        cell.replyText.text = reply.reply
//        cell.usernameLabel.text = reply.fromUser?.username
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "repliesTableView" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destinationViewController as! DetailViewController
                detail.question = obj
            }
        }
    }
}

