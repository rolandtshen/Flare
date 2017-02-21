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
import ChameleonFramework
import DZNEmptyDataSet

class QuestionsViewController: PFQueryTableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    var image: UIImage?
    var selectedCategory: String?
    var currLocation: CLLocationCoordinate2D?
    var reset: Bool = false
    let locationManager = CLLocationManager()
    
    var imagePickerController: UIImagePickerController?
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        self.loadObjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white]
        
        _ = Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(QuestionsViewController.queryForTable), userInfo: nil, repeats: true)
        self.tableView.backgroundColor = UIColor(hexString: "f2f2f2")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func unwindToQuestionsViewController(_ segue: UIStoryboardSegue) {
    }

    //MARK: Downloads
    
    func getBlockedUsers(_ completionHandler: ([PFUser]) -> Void) {
        var blockedUsers: [PFUser] = []
        let query = Block.query()!
        query.whereKey("fromUser", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error) in
            if(error == nil) {
                let blocks = objects as? [Block]
                for block in blocks! {
                    blockedUsers.append(block.toUser!)
                }
            }
        }
        completionHandler(blockedUsers)
    }

    
    func getProfilePic(_ user: PFUser, completionHandler: @escaping (UIImage) -> Void) {
        let profile = user
        if let picture = profile.object(forKey: "profilePic") as? PFFile {
            picture.getDataInBackground(block: { (data, error) in
                if (data != nil) {
                    completionHandler(UIImage(data: data!)!)
                }
            })
        }
    }
    
    func getNumReplies(_ object: PFObject, completionHandler: @escaping (Int) -> Void) {
        let question = object as! Question
        let query = PFQuery(className: "Reply")
        query.includeKey("toPost")
        query.whereKey("toPost", equalTo: question)
        query.findObjectsInBackground { (objects, error) in
            completionHandler(objects!.count)
        }
    }
    
    func getImage(object: PFObject, completionHandler: @escaping (UIImage) -> Void) {
        let question = object as! Question
        if let picture = question.imageFile {
            picture.getDataInBackground(block: { (data, error) in
                if(error == nil) {
                    completionHandler(UIImage(data: data!)!)
                }
            })
        }
    }
    
    //MARK: Image Picker Methods
    func imageTapped(_ gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            // Allow user to choose between photo library and camera
            let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .default) { (action) in
                self.showImagePickerController(.photoLibrary)
            }
            
            alertController.addAction(photoLibraryAction)
            
            // Only show camera option if rear camera is available
            if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
                let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
                    self.showImagePickerController(.camera)
                }
                alertController.addAction(cameraAction)
            }
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func showImagePickerController(_ sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        present(imagePickerController!, animated: true, completion: nil)
    }
    
    //MARK: Table View Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let question = object as? Question
        var pickedCell = PFTableViewCell()
        let colorPicker = CategoryHelper()
        
        getBlockedUsers { (blockedUsers) in
            if(blockedUsers.contains((question?.user)!)) {
                let blockedCell = tableView.dequeueReusableCell(withIdentifier: "blockedContentCell") as! PFTableViewCell
                pickedCell = blockedCell
            }
        }
        
        if question!.hasImage == true {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "QuestionImageCell", for: indexPath) as! QuestionImageCell
            imageCell.profilePicView.layer.cornerRadius = imageCell.profilePicView.frame.width/2
            imageCell.profilePicView.clipsToBounds = true
            imageCell.post = question
            imageCell.questionLabel.text = question!.question
            imageCell.timeLabel.text = (question!.createdAt as NSDate?)?.shortTimeAgo(since: Date())
            imageCell.usernameLabel.setTitle(question!.user?.username, for: UIControlState())
            imageCell.categoryFlag.backgroundColor = colorPicker.colorChooser(question!.category!)
            imageCell.categoryLabel.text = question!.category
            imageCell.postImage.clipsToBounds = true
            imageCell.imageView?.image = nil
            
            question?.fetchLikes()
            
            getProfilePic(question!.user!, completionHandler: { (profilePic) in
                imageCell.profilePicView?.image = profilePic
            })
            
            getNumReplies(object!, completionHandler: { (numReplies) in
                if(numReplies == 0) {
                    imageCell.repliesLabel.text = ""
                }
                else if (numReplies == 1) {
                    imageCell.repliesLabel.text = "1 reply"
                }
                else {
                    imageCell.repliesLabel.text = "\(numReplies) replies"
                }
            })
            
            getImage(object: object!, completionHandler: { (image) in
                imageCell.postImage.image = image
            })
            
            pickedCell = imageCell
            
        } else if question!.hasImage == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
            cell.profilePicView.layer.cornerRadius = cell.profilePicView.frame.width/2
            cell.profilePicView.clipsToBounds = true
            cell.post = question
            cell.categoryLabel.text = question!.category
            cell.questionLabel.text = question!.question
            cell.timeLabel.text = (question!.createdAt as NSDate?)?.shortTimeAgo(since: Date())
            cell.usernameLabel.setTitle(question!.user?.username, for: UIControlState())
            cell.categoryFlag.backgroundColor = colorPicker.colorChooser(question!.category!)
            
            question?.fetchLikes()
            
            getProfilePic(question!.user!, completionHandler: { (profilePic) in
                cell.profilePicView?.image = profilePic
            })
            cell.likesLabel.sizeToFit()
            
            getNumReplies(object!, completionHandler: { (numReplies) in
                if(numReplies == 0) {
                    cell.repliesLabel.text = ""
                }
                else if (numReplies == 1) {
                    cell.repliesLabel.text = "1 reply"
                }
                else {
                    cell.repliesLabel.text = "\(numReplies) replies"
                }
            })
            
            pickedCell = cell
        }
        return pickedCell
    }
    //MARK: Query for location

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0) {
            let location = locations[locations.count - 1]
            currLocation = location.coordinate
            self.loadObjects()
        }
        else {
           // alert.showError("Error", subTitle: "Please enable location services in settings!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        let alert = SCLAlertView()
//        alert.showError("Error", subTitle: "Please enable location services in settings!")
    }
    
    override func object(at indexPath: IndexPath!) -> PFObject? {
        var obj: PFObject? = nil
        if(indexPath.row < self.objects!.count){
            obj = self.objects![indexPath.row] as PFObject
        }
        
        return obj
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = Question.query()!
        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: 4)
            query.limit = 100;
        }
        else {
            query.whereKey("nothing", equalTo: "nothing")
        }
        query.order(byDescending: "createdAt")
        query.includeKey("user")
        print("queried")
        return query
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "questionDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destination as! DetailContainerViewController
                detail.question = obj
            }
            if identifier == "questionImageDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destination as! DetailContainerViewController
                detail.question = obj
            }
        }
    }
}

extension QuestionsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "There's nothing here!"
        let changes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 24.0)!, NSForegroundColorAttributeName: UIColor.flatGray()] as [String : Any]
        
        return NSAttributedString(string: str, attributes: changes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Enable location services or be the first poster in your area!"
        let attrs = [NSFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.flatGray()] as [String : Any]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "exclamation_mark_filled")
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return UIImage(named: "newquestionbutton")
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        performSegue(withIdentifier: "newQuestion", sender: self)
    }
}
