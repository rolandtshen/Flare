//
//  Message.swift
//  Questions
//
//  Created by Roland Shen on 7/26/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse
import JSQMessagesViewController

class Message: PFObject, PFSubclassing, JSQMessageData {
    
    @NSManaged var fromUser: PFUser?
    @NSManaged var toUser: PFUser?
    @NSManaged var convo: Conversation
    @NSManaged var messageText: String?
    @NSManaged var attachment: PFFile?
    @NSManaged var convoId: String?
    @NSManaged var senderName: String?
    
    func senderId() -> String! {
        return fromUser?.objectId
    }
    
    func senderDisplayName() -> String! {
        return fromUser?.username
    }
    
    func messageHash() -> UInt {
        return 0    }
    
    func date() -> Date! {
        return self.createdAt
    }
    
    func isMediaMessage() -> Bool {
        return true
    }
    
    func text() -> String! {
        return messageText
    }
    
    class func parseClassName() -> String {
        return "Message"
    }
}
