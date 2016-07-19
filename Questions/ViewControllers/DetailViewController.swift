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

class DetailViewController: PFQueryTableViewController, UINavigationControllerDelegate {
    
    var question: PFObject?
    var numReplies: Int?
    
    @IBOutlet weak var originalQuestionView: UIView!
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyField: UITextField!

    @IBAction func sendButton(sender: AnyObject) {
    }
    override func viewDidLoad() {
        //allows all reply cells to change dynamically based on answer length
        tableView.estimatedRowHeight = 125.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let user = question?.objectForKey("user") as? PFUser
        posterNameLabel.text = user?.username
        questionTextLabel.text = question?.objectForKey("question") as? String
        timeLabel.text = question?.createdAt?.shortTimeAgoSinceDate(NSDate())
        
        if let imageFile = question?.objectForKey("imageFile") as? PFFile {
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    let image = UIImage(data: imageData!)
              //      self.postImage.image = image
                }
                else {
                    print("Error: \(error)")
                }
            }
            //postImage.sizeToFit()
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReplyCell", forIndexPath: indexPath) as! ReplyCell
            
            cell.usernameLabel.text = "name test"
            cell.replyText.text = "reply test"
            cell.selectionStyle = .None
            
            return cell
    }

//    override func queryForTable() -> PFQuery {
//        let query = PFQuery(className: "Reply")
//        return query
//    }
}

