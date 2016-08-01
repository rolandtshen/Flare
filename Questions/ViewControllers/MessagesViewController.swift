

import UIKit
import Parse
import ParseUI
import JSQMessagesViewController

class MessagesViewController: PFQueryTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessagesCell
        let convo = object
        
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width / 2
        cell.profilePic.clipsToBounds = true
        
        cell.messagePreview.text = "message"
        cell.profilePic.image = UIImage(named: "default")
        cell.timestamp.text = convo!.createdAt?.shortTimeAgoSinceDate(NSDate())
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
}
