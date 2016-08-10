//
//  QuestionsViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Parse
import ParseUI
import DateTools
import SCLAlertView
import ChameleonFramework
import DZNEmptyDataSet

class QuestionsViewController: PFQueryTableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var image: UIImage?
    var selectedCategory: String?
    var currLocation: CLLocationCoordinate2D?
    var reset: Bool = false
    let locationManager = CLLocationManager()
    
    var imagePickerController: UIImagePickerController?
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 20.0)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        _ = NSTimer.scheduledTimerWithTimeInterval(120.0, target: self, selector: #selector(QuestionsViewController.queryForTable), userInfo: nil, repeats: true)
        self.tableView.backgroundColor = UIColor(hexString: "f2f2f2")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 5
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func unwindToQuestionsViewController(segue: UIStoryboardSegue) {
    }
    
    //MARK: Likes
//    
//    func like(post: Question) {
//        LikeHelper.toggleLikePost(PFUser.currentUser()!, post: post) { (isLiked) in
//            
//            if isLiked {
//                self.likesLabel.text = "♥️ Likes (\(self.numberOfLikes - 1))"
//                self.numberOfLikes = self.numberOfLikes - 1
//            } else {
//                self.likesLabel.text = "♥️ Likes (\(self.numberOfLikes + 1))"
//                self.numberOfLikes = self.numberOfLikes + 1
//            }
//        }
//
//    }
    
    //MARK: Downloads
    
    func getNumLikes(object: PFObject, completionHandler: (Int) -> Void) {
        let question = object as! Question
        let query = PFQuery(className: "Like")
        query.includeKey("toPost")
        query.whereKey("toPost", equalTo: question)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                completionHandler(objects!.count)
            }
        }
    }
    
    func getNumReplies(object: PFObject, completionHandler: (Int) -> Void) {
        let question = object as! Question
        let query = PFQuery(className: "Reply")
        query.includeKey("toPost")
        query.whereKey("toPost", equalTo: question)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            completionHandler(objects!.count)
        }
    }
    
    func getImage(object: PFObject, completionHandler: (UIImage) -> Void) {
        let question = object as! Question
        if let picture = question.imageFile {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }

    //MARK: Image Picker Methods
    func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            // Allow user to choose between photo library and camera
            let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
                self.showImagePickerController(.PhotoLibrary)
            }
            
            alertController.addAction(photoLibraryAction)
            
            // Only show camera option if rear camera is available
            if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
                let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in
                    self.showImagePickerController(.Camera)
                }
                alertController.addAction(cameraAction)
            }
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
    //MARK: Table View Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let question = object as! Question
        var pickedCell = PFTableViewCell()
        let colorPicker = CategoryHelper()
        
        if question.hasImage == true {
            let imageCell = tableView.dequeueReusableCellWithIdentifier("QuestionImageCell", forIndexPath: indexPath) as! QuestionImageCell
            imageCell.post = question
            imageCell.questionLabel.text = question.question
            imageCell.timeLabel.text = question.createdAt?.shortTimeAgoSinceDate(NSDate())
            imageCell.usernameLabel.text = question.user?.username
            imageCell.categoryFlag.backgroundColor = colorPicker.colorChooser(question.category!)
            imageCell.postImage.clipsToBounds = true
            imageCell.imageView?.image = nil
            if(question.likes != nil) {
                imageCell.likesLabel.titleLabel!.text = "♥️ Likes (\(question.likes?.stringValue))"
            }
            
            getNumReplies(object!, completionHandler: { (numReplies) in
                imageCell.repliesLabel.text = "Replies (\(numReplies))"
            })
            
            getNumLikes(object!, completionHandler: { (numLikes) in
                imageCell.numberOfLikes = numLikes
                imageCell.likesLabel.titleLabel?.text = "♥️Likes (\(numLikes))"

            })
            
            getImage(object!, completionHandler: { (image) in
                imageCell.postImage.image = image
            })
            
            pickedCell = imageCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
            cell.post = question
            cell.questionLabel.text = question.question
            cell.timeLabel.text = question.createdAt?.shortTimeAgoSinceDate(NSDate())
            cell.usernameLabel.text = question.user?.username
            cell.categoryFlag.backgroundColor = colorPicker.colorChooser(question.category!)
            
            getNumReplies(object!, completionHandler: { (numReplies) in
                cell.repliesLabel.text = "Replies (\(numReplies))"
            })
            
            getNumLikes(object!, completionHandler: { (numLikes) in
                cell.numberOfLikes = numLikes
                cell.likesLabel.titleLabel?.text = "♥️Likes (\(numLikes))"
            })
            pickedCell = cell
        }
        return pickedCell
    }
    //MARK: Query for location

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let alert = SCLAlertView()
        if(locations.count > 0) {
            let location = locations[locations.count - 1]
            currLocation = location.coordinate
            self.loadObjects()
        }
        else {
            alert.showError("Error", subTitle: "Please enable location services in settings!")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Please enable location services in settings!")
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject? {
        var obj: PFObject? = nil
        if(indexPath.row < self.objects!.count){
            obj = self.objects![indexPath.row] as PFObject
        }
        
        return obj
    }
    
    override func queryForTable() -> PFQuery {
        let query = Question.query()!
        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: 4)
            query.limit = 100;
        }
        else {
            query.whereKey("nothing", equalTo: "nothing")
        }
        query.orderByDescending("createdAt")
        query.includeKey("user")
        print("queried")
        return query
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "questionDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destinationViewController as! DetailContainerViewController
                detail.question = obj
            } else if identifier == "questionImageDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destinationViewController as! DetailContainerViewController
                detail.question = obj
            }
        }
    }
}

extension QuestionsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "No posts found"
        let changes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 24.0)!, NSForegroundColorAttributeName: UIColor.flatGrayColor()]
        
        return NSAttributedString(string: str, attributes: changes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Enable location services or be the first poster in your area!"
        let attrs = [NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.flatGrayColor()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "exclamation_mark_filled")
    }
    
    func buttonImageForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> UIImage! {
        return UIImage(named: "newquestionbutton")
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        performSegueWithIdentifier("newQuestion", sender: self)
    }
}