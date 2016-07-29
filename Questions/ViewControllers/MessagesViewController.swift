//
//  InitalTableViewController.swift
//  SwiftExample
//
//  Created by P D Leonard on 7/22/16.
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import JSQMessagesViewController

class MessagesViewController: PFQueryTableViewController {

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessagesCell
        
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width / 2
        cell.profilePic.clipsToBounds = true
        
        cell.messagePreview.text = "message"
        cell.profilePic.image = UIImage(named: "default")
        cell.timestamp.text = "time"
        cell.nameLabel.text = "name"
        return cell
    }
    
    //I want to make this tableview filled with people that they have chatted with before
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Post")
        return query
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "chatSegue" {
                let navVc = segue.destinationViewController as! ChatViewController
                navVc.senderId = PFUser.currentUser()?.objectId
                navVc.senderDisplayName = PFUser.currentUser()?.username
            }
        }
    }
}
