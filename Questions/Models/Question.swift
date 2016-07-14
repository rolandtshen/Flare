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
import CoreLocation

class Question: PFObject {
   
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var location: CLLocationCoordinate2D?
    var uploadTask: UIBackgroundTaskIdentifier?
    var category: String?
    var question: String?
    var image: UIImage?
    var postDate: NSDate?
    var numReplies: Int?
    
    init(category: String, question: String, location: CLLocationCoordinate2D) {
        self.category = category
        self.question = question
        self.location = location
        super.init()
    }
    
    func uploadPost() {
        let post = PFObject(className: "Post")
        post["question"] = question
        if(image != nil) {
            post["imageFile"] = imageFile
        }
        post["location"] = PFGeoPoint(latitude: location!.latitude, longitude: location!.longitude)
       // post["user"] = PFUser.currentUser()
        
        post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
               print("Success with posting")
            }
            else {
               print("Error with posting")
            }
        }
    }
}