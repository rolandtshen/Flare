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

class Question: PFObject, PFSubclassing {
   
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var location: CLLocationCoordinate2D?
    var category: String?
    var question: String?
    var image: UIImage?
    var numReplies: Int?
    
    override init() {
        self.location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.category = "Category"
        self.question = "????????"
        self.image = nil
        self.numReplies = 0
        super.init()
    }
    
    init(category: String, question: String, location: CLLocationCoordinate2D) {
        self.category = category
        self.question = question
        self.location = location
        super.init()
    }
    
    class func parseClassName() -> String {
        return "Post"
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
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
}