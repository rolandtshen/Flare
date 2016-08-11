
import JSQMessagesViewController
import Parse
import ChameleonFramework
import SCLAlertView

class ChatViewController: JSQMessagesViewController {
    
    // Get selected conversation from MessagesViewController, then use a query to get all messages with that conversation
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.flatWhiteColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(hexString: "2796c2                                                 "))
    
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var messages = [JSQMessage]()
    
    var conversation: Conversation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(conversation?.toUser!.username == PFUser.currentUser()!.username) {
            title = conversation!.fromUser?.username
        }
        else if(conversation?.fromUser!.username == PFUser.currentUser()?.username) {
            title = conversation!.toUser!.username
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadMessagesView), name: "new_message", object: nil)
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        downloadLatestMessage()
        self.collectionView.reloadData()
    }
}


//MARK: Setup
extension ChatViewController {
    func setup() {
        self.senderId = PFUser.currentUser()?.objectId
        self.senderDisplayName = PFUser.currentUser()?.username
        self.downloadMessages()
    }
    
    //Not using this yet
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(senderDisplayName.startIndex.advancedBy(min(3, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
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
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        cell.textView!.text = message.text
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.senderId == senderId {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return nil;
            }
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.senderId == self.senderId {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}

//MARK - Toolbar
extension ChatViewController {
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.sendMessage(message)
        self.messages.append(message)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
//        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .ActionSheet)
//        
//        let photoAction = UIAlertAction(title: "Send photo", style: .Default) { (action) in
//            /**
//             *  Create fake photo
//             */
//            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
//            self.addMedia(photoItem)
//        }
//        
//        let locationAction = UIAlertAction(title: "Send location", style: .Default) { (action) in
//            /**
//             *  Add fake location
//             */
//            let locationItem = self.buildLocationItem()
//            
//            self.addMedia(locationItem)
//        }
//        
//        let videoAction = UIAlertAction(title: "Send video", style: .Default) { (action) in
//            /**
//             *  Add fake video
//             */
//            let videoItem = self.buildVideoItem()
//            
//            self.addMedia(videoItem)
//        }
//        
//        let audioAction = UIAlertAction(title: "Send audio", style: .Default) { (action) in
//            /**
//             *  Add fake audio
//             */
//            let audioItem = self.buildAudioItem()
//            
//            self.addMedia(audioItem)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
//        sheet.addAction(photoAction)
//        sheet.addAction(locationAction)
//        sheet.addAction(videoAction)
//        sheet.addAction(audioAction)
//        sheet.addAction(cancelAction)
        
        //self.presentViewController(sheet, animated: true, completion: nil)
        let alert = SCLAlertView()
        alert.showError("Sorry!", subTitle: "This feature isn't ready yet!")
    }
}

//MARK: Accessories
extension ChatViewController {
    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = NSURL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        return videoItem
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = NSBundle.mainBundle().pathForResource("jsq_messages_sample", ofType: "m4a")
        let audioData = NSData(contentsOfFile: sample!)
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        self.messages.append(message)
        
        //Optional: play sent sound
        
        self.finishSendingMessageAnimated(true)
    }
}

//MARK: Parse
extension ChatViewController {
    
    func sendMessage(message: JSQMessage) {
        let messageToSend = Message()
        messageToSend.messageText = message.text
        messageToSend.fromUser = PFUser.currentUser()
        if(conversation!.toUser != PFUser.currentUser()) {
            messageToSend.toUser = conversation?.toUser
        }
        else {
            messageToSend.toUser = conversation?.fromUser
        }

        messageToSend.convo = self.conversation!
        messageToSend.convoId = self.conversation!.objectId
        messageToSend.saveInBackground()
    }
    
    func downloadMessages() {
        let query = PFQuery(className: "Message")
        query.includeKey("convo")
        query.includeKey("toUser")
        query.includeKey("fromUser")
        query.whereKey("convo", equalTo: conversation!)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            let parseMessages = objects as! [Message]
            let messages: [JSQMessage] = parseMessages.map({ return self.jsqMessageFromParse($0) }) as [JSQMessage]
            self.messages = messages
            self.finishReceivingMessage()
        }
    }

    func downloadLatestMessage() {
        let query = PFQuery(className: "Message")
        query.includeKey("convo")
        query.includeKey("toUser")
        query.includeKey("fromUser")
        query.whereKey("convo", equalTo: conversation!)
        query.orderByDescending("createdAt")
        query.getFirstObjectInBackgroundWithBlock {(object: PFObject?, error: NSError?) -> Void in
            let parseMessage = object as! Message
            print(parseMessage.fromUser)
            if parseMessage.fromUser?.email == PFUser.currentUser()?.email {
                self.messages.append(self.jsqMessageFromParse(parseMessage))
            }
            
            self.finishReceivingMessage()
        }
    }
    
    func jsqMessageFromParse(message: Message) -> JSQMessage {
//        guard let fromUser = message.fromUser else { fatalError() }
//        let text: String = message.messageText!
//        let date: NSDate = message.createdAt!
//        let senderId: String = fromUser.objectId!
//        let senderDisplayName: String = fromUser.username!
//        
//        return JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        return JSQMessage(senderId: message.senderId(), senderDisplayName: message.senderDisplayName(), date: message.date(), text: message.text())
    }
}
