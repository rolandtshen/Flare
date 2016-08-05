//
//  ProfileViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import ParseUI
import Parse

class ProfileViewController: PFQueryTableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var questionsLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    
    let colorPicker = CategoryHelper()
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        fullNameLabel.text = PFUser.currentUser()?.objectForKey("name") as? String
        profilePicView.layer.cornerRadius = profilePicView.frame.width / 2
        profilePicView.clipsToBounds = true
        getProfilePic(PFUser.currentUser()!, completionHandler: { (image) in
            self.profilePicView.image = image
        })
        bioLabel.text = PFUser.currentUser()?.objectForKey("bio") as? String
        self.loadObjects()
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Post")
        query.includeKey("user")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.orderByDescending("createdAt")
        query.limit = 5
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("profilePostCell") as! ProfileCellView
        let question = object as! Question
        cell.categoryLabel.text = question.category
        cell.categoryBox.backgroundColor = colorPicker.colorChooser(question.category!)
        cell.questionLabel.text = question.question
        cell.timeLabel.text = question.createdAt?.shortTimeAgoSinceDate(NSDate())
        return cell
    }
    
    func getProfilePic(object: PFObject, completionHandler: (UIImage) -> Void) {
        let profile = object as! PFUser
        if let picture = profile.objectForKey("profilePic") {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    func getBio(object: PFObject, completionHandler: (UIImage) -> Void) {
        let profile = object as! PFUser
        if let picture = profile.objectForKey("profilePic") {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    @IBAction func unwindToProfileViewController(segue: UIStoryboardSegue) {
    }
}