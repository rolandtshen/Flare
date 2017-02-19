
import JSQMessagesViewController
import Parse
import ChameleonFramework
import SCLAlertView
import Mixpanel

class ChatViewController: JSQMessagesViewController {

    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.flatWhite())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.flatWatermelon())
    
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var messages = [JSQMessage]()
    
    var conversation: Conversation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Mixpanel.sharedInstance().track("Chat opened")
        if(conversation?.toUser!.username == PFUser.current()!.username) {
            title = conversation!.fromUser?.username
        }
        else if(conversation?.fromUser!.username == PFUser.current()?.username) {
            title = conversation!.toUser!.username
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMessagesView), name: NSNotification.Name(rawValue: "new_message"), object: nil)
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        DispatchQueue.main.async {
            self.downloadLatestMessage()
            self.collectionView.reloadData()
        }
    }
}


//MARK: Setup
extension ChatViewController {
    func setup() {
        self.senderId = PFUser.current()?.objectId
        self.senderDisplayName = PFUser.current()?.username
        self.downloadMessages()
    }
    
    //Not using this yet
    func setupAvatarImage(_ name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = URL(string: stringUrl) {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(_ name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substring(to: senderDisplayName.index(senderDisplayName.startIndex, offsetBy: min(3, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: color, textColor: UIColor.black, font: UIFont.systemFont(ofSize: CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
}

//MARK - Data Source
extension ChatViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
        } else {
            cell.textView!.textColor = UIColor.black
        }
        cell.textView!.text = message.text
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // View  usernames above bubbles
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
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
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.sendMessage(message!)
        self.messages.append(message!)
        Mixpanel.sharedInstance().track("Message sent")
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
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
        let videoURL = URL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        return videoItem!
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
        
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
    
    func addMedia(_ media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        self.messages.append(message!)
        
        //Optional: play sent sound
        
        self.finishSendingMessage(animated: true)
    }
}

//MARK: Parse
extension ChatViewController {
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func sendMessage(_ message: JSQMessage) {
        let messageToSend = Message()
        messageToSend.messageText = message.text
        messageToSend.fromUser = PFUser.current()
        if(conversation!.toUser != PFUser.current()) {
            messageToSend.toUser = conversation?.toUser
            messageToSend.senderName = conversation?.fromUser?.username
        }
        else {
            messageToSend.toUser = conversation?.fromUser
            messageToSend.senderName = conversation?.fromUser?.username
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
        query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
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
        query.order(byDescending: "createdAt")
        query.getFirstObjectInBackground {(object: PFObject?, error: NSError?) -> Void in
            let parseMessage = object as! Message
            print(parseMessage.fromUser)
            self.messages.append(self.jsqMessageFromParse(parseMessage))
            self.finishReceivingMessage()
        }
    }
    
    func jsqMessageFromParse(_ message: Message) -> JSQMessage {
        return JSQMessage(senderId: message.senderId(), senderDisplayName: message.senderDisplayName(), date: message.date() as Date!, text: message.text())
    }
}
