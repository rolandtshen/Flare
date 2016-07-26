
import Foundation
import UIKit
import JSQMessagesViewController
import Parse

class ChatViewController: JSQMessagesViewController {
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.flatGrayColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.flatSkyBlueColor())
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        self.downloadMessages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
}

extension ChatViewController {
    func setup() {
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
}

//MARK - Data Source
extension ChatViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

//MARK - Toolbar
extension ChatViewController {
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.sendMessageToParse(message)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}

//MARK - Parse
extension ChatViewController {
    
    func sendMessageToParse(message: JSQMessage) {
        let messageToSend = Message()
        messageToSend.text = message.text
        messageToSend.fromUser = PFUser.currentUser()
        messageToSend.saveInBackground()
    }
    
    func downloadMessages() {
        let query = PFQuery(className: "Message")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let messages = objects as? [Message] {
                self.messages = self.jsqMessagesFromParse(messages)
            }
        }
    }

    func jsqMessageFromParse(message: Message) -> JSQMessage {
        let jsqMessage = JSQMessage(senderId: message.fromUser?.objectId, senderDisplayName: message.fromUser?.username, date: message.createdAt, text: message.text)
        return jsqMessage
    }
    
    func jsqMessagesFromParse(messages: [Message]) -> [JSQMessage] {
        var jsqMessages : [JSQMessage] = []
        for message in messages {
            jsqMessages.append(self.jsqMessageFromParse(message))
        }
        return jsqMessages
    }
}