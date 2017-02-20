

import UIKit
import Parse
import ParseUI
import JSQMessagesViewController
import DZNEmptyDataSet

class MessagesViewController: PFQueryTableViewController {
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadObjects()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessagesCell
        let convo = object
        
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.width / 2
        cell.profilePic.clipsToBounds = true
        
        if((convo?.value(forKey: "toUser") as? PFUser) != PFUser.current()) {
            getProfilePic(convo?.value(forKey: "toUser") as! PFUser, completionHandler: { (profilePic) in
                cell.profilePic.image = profilePic
            })
        }
        else if((convo?.value(forKey: "fromUser") as? PFUser) != PFUser.current()) {
            getProfilePic(convo?.value(forKey: "fromUser") as! PFUser, completionHandler: { (profilePic) in
                cell.profilePic.image = profilePic
            })
        }
        
        downloadLatestMessage(object!, completionHandler: { (message) in
            cell.messagePreview.text = message.messageText
        })
        
        downloadLatestMessage(object!, completionHandler: { (message) in
            cell.timestamp.text = (message.createdAt as NSDate?)?.shortTimeAgo(since: Date())
        })
        
        if((convo?.value(forKey: "toUser") as? PFUser) != PFUser.current()) {
            let toUser = convo?.value(forKey: "toUser") as! PFUser
            cell.nameLabel.text = toUser.username
        }
        else if((convo?.value(forKey: "fromUser") as? PFUser) != PFUser.current()) {
            let fromUser = convo?.value(forKey: "fromUser") as! PFUser
            cell.nameLabel.text = fromUser.username
        }
        
        return cell
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let queryFromUser = Conversation.query()
        queryFromUser!.whereKey("fromUser", equalTo: PFUser.current()!)
        let queryToUser = Conversation.query()
        queryToUser!.whereKey("toUser", equalTo: PFUser.current()!)
        
        let query = PFQuery.orQuery(withSubqueries: [queryFromUser!, queryToUser!])
        query.order(byDescending: "createdAt")
        query.includeKey("toUser")
        query.includeKey("fromUser")
        
        return query
    }
    
    override func object(at indexPath: IndexPath!) -> PFObject? {
        var obj: PFObject? = nil
        if(indexPath.row < self.objects!.count){
            obj = self.objects![indexPath.row] as PFObject
        }
        return obj
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "chatSegue" {
                let chatViewController = segue.destination as! ChatViewController
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = object(at: indexPath) as? Conversation
                chatViewController.conversation = obj
            }
        }
    }
    
    func downloadLatestMessage(_ object: PFObject, completionHandler: @escaping (Message) -> Void) {
        let conversation = object as! Conversation
        let query = PFQuery(className: "Message")
        query.includeKey("convo")
        query.includeKey("toUser")
        query.includeKey("fromUser")
        query.whereKey("convo", equalTo: conversation)
        query.order(byDescending: "createdAt")
        query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
            if(error == nil) {
                completionHandler(object as! Message)
            }
        }
    }
    
    func getProfilePic(_ user: PFUser, completionHandler: @escaping (UIImage) -> Void) {
        let profile = user
        if let picture = profile.object(forKey: "profilePic") as? PFFile {
            picture.getDataInBackground(block: { (data, error) in
                if (data != nil) {
                    completionHandler(UIImage(data: data!)!)
                }
            })
        }
    }
    
    @IBAction func unwindToMessagesViewController(_ segue: UIStoryboardSegue) {
    }
}

extension MessagesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "You don't have any messages!"
        let changes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 24.0)!, NSForegroundColorAttributeName: UIColor.flatGray()] as [String : Any]
        
        return NSAttributedString(string: str, attributes: changes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Find a post and press the chat icon to start a conversation."
        let attrs = [NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.flatGray()] as [String : Any]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "exclamation_mark_filled")
    }
}
