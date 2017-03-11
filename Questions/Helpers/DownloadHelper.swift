//
//  DownloadHelper.swift
//  Questions
//
//  Created by Roland Shen on 2/22/17.
//  Copyright © 2017 Roland Shen. All rights reserved.
//

import Foundation
import Parse

class DownloadHelper {
    
    public static func getProfilePic(_ user: PFUser, completionHandler: @escaping (UIImage) -> Void) {
        let profile = user
        if let picture = profile.object(forKey: "profilePic") as? PFFile {
            picture.getDataInBackground(block: { (data, error) in
                if (data != nil) {
                    completionHandler(UIImage(data: data!)!)
                }
            })
        }
    }
    
    public static func getBio(_ object: PFObject, completionHandler: @escaping (String) -> Void) {
        PFUser.current()?.fetchInBackground { user, error in
            if(user!["bio"] != nil) {
                completionHandler(user!["bio"] as! String)
            }
            else {
                completionHandler("You don't have a bio!")
            }
        }
    }
    
    public static func getUsername(_ completionHandler: @escaping (String) -> Void) {
        PFUser.current()?.fetchInBackground { user, error in
            completionHandler((PFUser.current()?.username)!)
        }
    }
    
    public static func getNumLikes(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Like")
        query.whereKey("fromUser", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumQuestions(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Post")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumAnswers(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Reply")
        query.whereKey("fromUser", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
}
