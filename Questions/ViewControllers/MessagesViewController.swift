

import UIKit
import Parse
import ParseUI
import JSQMessagesViewController

class MessagesViewController: PFQueryTableViewController {
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        self.loadObjects()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessagesCell
        let convo = object
        
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width / 2
        cell.profilePic.clipsToBounds = true
        
        downloadLatestMessage(object!, completionHandler: { (message) in
            cell.messagePreview.text = message.messageText
        })
        
        downloadLatestMessage(object!, completionHandler: { (message) in
            cell.timestamp.text = message.createdAt?.shortTimeAgoSinceDate(NSDate())
        })
        
        if((convo?.valueForKey("toUser") as? PFUser) != PFUser.currentUser()) {
            let toUser = convo?.valueForKey("toUser") as! PFUser
            cell.nameLabel.text = toUser.username
        }
        else if((convo?.valueForKey("fromUser") as? PFUser) != PFUser.currentUser()) {
            let fromUser = convo?.valueForKey("fromUser") as! PFUser
            cell.nameLabel.text = fromUser.username
        }
        
        return cell
    }
    
    override func queryForTable() -> PFQuery {
        let queryFromUser = Conversation.query()
        queryFromUser!.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        let queryToUser = Conversation.query()
        queryToUser!.whereKey("toUser", equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([queryFromUser!, queryToUser!])
        query.orderByDescending("createdAt")
        query.includeKey("toUser")
        query.includeKey("fromUser")
        
        return query
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject? {
        var obj: PFObject? = nil
        if(indexPath.row < self.objects!.count){
            obj = self.objects![indexPath.row] as PFObject
        }
        return obj
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "chatSegue" {
                let chatViewController = segue.destinationViewController as! ChatViewController
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = objectAtIndexPath(indexPath) as? Conversation
                chatViewController.conversation = obj
            }
        }
    }
    
    func downloadLatestMessage(object: PFObject, completionHandler: (Message) -> Void) {
        let conversation = object as! Conversation
        let query = PFQuery(className: "Message")
        query.includeKey("convo")
        query.includeKey("toUser")
        query.includeKey("fromUser")
        query.whereKey("convo", equalTo: conversation)
        query.orderByDescending("createdAt")
        query.getFirstObjectInBackgroundWithBlock {(object: PFObject?, error: NSError?) -> Void in
            if(error == nil) {
                completionHandler(object as! Message)
            }
        }
    }
}
