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
import SlackTextViewController

class DetailViewController: PFQueryTableViewController, UINavigationControllerDelegate {
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReplyCell", forIndexPath: indexPath) as! ReplyCell
        cell.usernameLabel.text = "name test"
        cell.replyText.text = "reply test"
        cell.selectionStyle = .None
        return cell
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Post")
        return query
    }
}

