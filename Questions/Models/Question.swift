//
//  Question.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse

class Question: PFObject {
    var category: String?
    var question: String?
    var hasImage: Bool?
    var image: UIImage?
    var postDate: NSDate?
    var numReplies: Int?
    
    
//    func uploadPost() {
//        
//        if let image = image.value {
//            
//            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
//            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
//            
//            user = PFUser.currentUser()
//            self.imageFile = imageFile
//            
//            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
//                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
//            }
//            
//            saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
//            }
//        }
//    }
//    
//    func downloadImage() {
//        image.value = Post.imageCache[self.imageFile!.name]
//        
//        // if image is not downloaded yet, get it
//        if (image.value == nil) {
//            
//            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
//                if let data = data {
//                    let image = UIImage(data: data, scale:1.0)!
//                    self.image.value = image
//                    // 2
//                    Post.imageCache[self.imageFile!.name] = image
//                }
//            }
//        }
//    }
//    
//    func fetchLikes() {
//        if (likes.value != nil) {
//            return
//        }
//        
//        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
//            
//            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
//            
//            self.likes.value = validLikes?.map {
//                like in let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
//                
//                return fromUser
//            }
//        })
//    }
//    
//    func doesUserLikePost(user: PFUser) -> Bool {
//        if let likes = likes.value {
//            return likes.contains(user)
//        } else {
//            return false
//        }
//    }
//    
//    func toggleLikePost(user: PFUser) {
//        if (doesUserLikePost(user)) {
//            // if post is liked, unlike it now
//            likes.value = likes.value?.filter { $0 != user }
//            ParseHelper.unlikePost(user, post: self)
//        } else {
//            // if this post is not liked yet, like it now
//            likes.value?.append(user)
//            ParseHelper.likePost(user, post: self)
//        }
//    }
//    
//    override class func initialize() {
//        var onceToken : dispatch_once_t = 0;
//        dispatch_once(&onceToken) {
//            // inform Parse about this subclass
//            self.registerSubclass()
//            // 1
//            Post.imageCache = NSCacheSwift<String, UIImage>()
//        }
//    }
}