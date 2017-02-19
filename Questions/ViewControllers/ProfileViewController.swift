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
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white]
        
        profilePicView.layer.cornerRadius = profilePicView.frame.width / 2
        profilePicView.clipsToBounds = true
        
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        fullNameLabel.textAlignment = .center
        bioLabel.textAlignment = .center
        
        getUsername { (username) in
            self.fullNameLabel.text = username
        }
        
        getProfilePic(PFUser.current()!, completionHandler: { (image) in
            self.profilePicView.image = image
        })
        
        getNumLikes { (numLikes) in
            self.likesLabel.text = "\(numLikes)"
        }
        
        getNumAnswers { (numAnswers) in
            self.answersLabel.text = "\(numAnswers)"
        }
        
        getNumQuestions { (numQuestions) in
            self.questionsLabel.text = "\(numQuestions)"
        }
        
        getBio(PFUser.current()!) { (bio) in
            self.bioLabel.sizeToFit()
            self.bioLabel.text = bio
        }
        
        self.objectsPerPage = 5
        self.loadObjects()
    }
    
    // get posts made by current user
    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: "Post")
        query.includeKey("user")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        query.limit = 100
        return query
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profilePostCell") as! ProfileCellView
        let question = object as! Question
        cell.categoryLabel.text = question.category
        cell.categoryBox.backgroundColor = colorPicker.colorChooser(question.category!)
        cell.questionLabel.text = question.question
        cell.timeLabel.text = (question.createdAt as NSDate?)?.shortTimeAgo(since: Date())
        return cell
    }
    
    //MARK: Downloads
    
    func getProfilePic(_ object: PFUser, completionHandler: @escaping (UIImage) -> Void) {
        let profile = object
        if let picture = profile.object(forKey: "profilePic") {
            (picture as AnyObject).getDataInBackground(block: {
                (imageData: Data?, error: NSError?) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    func getBio(_ object: PFObject, completionHandler: @escaping (String) -> Void) {
        PFUser.current()?.fetchInBackground { user, error in
            if(user!["bio"] != nil) {
                completionHandler(user!["bio"] as! String)
            }
            else {
                completionHandler("You don't have a bio!")
            }
        }
    }
    
    func getUsername(_ completionHandler: @escaping (String) -> Void) {
        PFUser.current()?.fetchInBackground { user, error in
            completionHandler((PFUser.current()?.username)!)
        }
    }
    
    func getNumLikes(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Like")
        query.whereKey("fromUser", equalTo: PFUser.current()!)
        query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumQuestions(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Post")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumAnswers(_ completionHandler: @escaping (Int) -> Void) {
        let query = PFQuery(className: "Reply")
        query.whereKey("fromUser", equalTo: PFUser.current()!)
        query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    //MARK: Segue Methods
    
    @IBAction func unwindToProfileViewController(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destination as! DetailContainerViewController
                detail.question = obj
            }
        }
    }
}
