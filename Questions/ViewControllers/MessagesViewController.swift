

import UIKit
import Parse
import ParseUI
import JSQMessagesViewController
import DZNEmptyDataSet

class MessagesViewController: PFQueryTableViewController {
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 20.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadObjects()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessagesCell
        let convo = object
        
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width / 2
        cell.profilePic.clipsToBounds = true
        
        if((convo?.valueForKey("toUser") as? PFUser) != PFUser.currentUser()) {
            getProfilePic(convo?.valueForKey("toUser") as! PFUser, completionHandler: { (profilePic) in
                cell.profilePic.image = profilePic
            })
        }
        else if((convo?.valueForKey("fromUser") as? PFUser) != PFUser.currentUser()) {
            getProfilePic(convo?.valueForKey("fromUser") as! PFUser, completionHandler: { (profilePic) in
                cell.profilePic.image = profilePic
            })
        }
        
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
    
    func getProfilePic(object: PFUser, completionHandler: (UIImage) -> Void) {
        let profile = object
        if let picture = profile.objectForKey("profilePic") {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }

    @IBAction func unwindToMessagesViewController(segue: UIStoryboardSegue) {
    }
}

extension MessagesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "You don't have any messages!"
        let changes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 24.0)!, NSForegroundColorAttributeName: UIColor.flatGrayColor()]
        
        return NSAttributedString(string: str, attributes: changes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Find a post and press the chat icon to start a conversation."
        let attrs = [NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.flatGrayColor()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "exclamation_mark_filled")
    }
}
