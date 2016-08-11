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
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        profilePicView.layer.cornerRadius = profilePicView.frame.width / 2
        profilePicView.clipsToBounds = true
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        fullNameLabel.textAlignment = .Center
        bioLabel.textAlignment = .Center
        
        getUsername { (username) in
            self.fullNameLabel.text = username
        }
        
        getProfilePic(PFUser.currentUser()!, completionHandler: { (image) in
            self.profilePicView.image = image
        })
        
        getNumAnswers { (numAnswers) in
            self.answersLabel.text = "\(numAnswers)"
        }
        
        getNumQuestions { (numQuestions) in
            self.questionsLabel.text = "\(numQuestions)"
        }
        
        getBio(PFUser.currentUser()!) { (bio) in
            self.bioLabel.sizeToFit()
            self.bioLabel.text = bio
        }
        
        self.objectsPerPage = 5
        self.loadObjects()
    }
    
    // get posts made by current user
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Post")
        query.includeKey("user")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.orderByDescending("createdAt")
        query.limit = 100
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
    
    //MARK: Downloads
    
    func getProfilePic(object: PFUser, completionHandler: (UIImage) -> Void) {
        let profile = object
        if let picture = profile.objectForKey("profilePic") {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    func getBio(object: PFObject, completionHandler: (String) -> Void) {
        PFUser.currentUser()?.fetchInBackgroundWithBlock { user, error in
            if(user!["bio"] != nil) {
                completionHandler(user!["bio"] as! String)
            }
            else {
                completionHandler("You don't have a bio!")
            }
        }
    }
    
    func getUsername(completionHandler: (String) -> Void) {
        PFUser.currentUser()?.fetchInBackgroundWithBlock { user, error in
            completionHandler((PFUser.currentUser()?.username)!)
        }
    }
    
//    func getLikes(object: PFObject, completionHandler: (UIImage) -> Void) {
//        let profile = object as! PFUser
//        if let picture = profile.objectForKey("profilePic") {
//            picture.getDataInBackgroundWithBlock({
//                (imageData: NSData?, error: NSError?) -> Void in
//                if (error == nil) {
//                    completionHandler(UIImage(data: imageData!)!)
//                }
//            })
//        }
//    }
    
    func getNumQuestions(completionHandler: (Int) -> Void) {
        let query = PFQuery(className: "Post")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumAnswers(completionHandler: (Int) -> Void) {
        let query = PFQuery(className: "Reply")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    //MARK: Segue Methods
    
    @IBAction func unwindToProfileViewController(segue: UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "showDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destinationViewController as! DetailContainerViewController
                detail.question = obj
            }
        }
    }
}