//
//  QuestionsViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import ParseUI
import DateTools
import ChameleonFramework
import SCLAlertView

class QuestionsViewController: PFQueryTableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var writeQuestionPic: UIImageView!
    @IBOutlet weak var writeQuestionTextView: UITextView!
    @IBOutlet weak var cameraButton: UIImageView!
    var image: UIImage?
    var downloadedImage: UIImage?
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
        writeQuestionTextView.delegate = self
        self.tableView.backgroundColor = UIColor.flatWhiteColor()
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 5
        
        self.writeQuestionTextView.selectedRange = NSMakeRange(0, 200);
        
        let gradientColors: [UIColor] = [UIColor.flatMintColor(), UIColor.flatSkyBlueColor()]
        tableView.backgroundColor = GradientColor(UIGradientStyle.TopToBottom, frame: view.frame, colors: gradientColors)
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        cameraButton.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuestionsViewController.imageTapped(_:)))
        cameraButton.addGestureRecognizer(tapGesture)
        
        tableView.reloadData()
    }

    @IBAction func categoryButton(sender: AnyObject) {
        let alertView = SCLAlertView()
        
        alertView.addButton("Travel", backgroundColor: UIColor.flatRedColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Travel"
        }

        alertView.addButton("Entertainment", backgroundColor: UIColor.flatOrangeColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Entertainment"
        }

        alertView.addButton("Meetup", backgroundColor: UIColor.flatYellowColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Meetup"
        }

        alertView.addButton("Listings", backgroundColor: UIColor.flatGreenColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Listings"
        }

        alertView.addButton("Recommendations", backgroundColor: UIColor.flatSkyBlueColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Listings"
        }
        alertView.addButton("Other", backgroundColor: UIColor.flatMagentaColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Other"
        }
        alertView.showNotice("Categories", subTitle: "")
    }
    
    
    func getImage(object: PFObject) {
        let question = object as! Question
        if let picture = question.imageFile {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.downloadedImage = UIImage(data: imageData!)
                }
            })
        }
        //self.tableView.reloadData()
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
    
    //MARK: Empty Data Set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "There haven't been any questions posted near you."
        let changes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        
        return NSAttributedString(string: str, attributes: changes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Be the first!"
        let attrs = [NSForegroundColorAttributeName : UIColor.blackColor()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ic_question_answer")
    }

    //MARK: Table View Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let question = object as! Question
        var pickedCell = PFTableViewCell()
        let colorPicker = CategoryHelper()
        
        if question.hasImage == true {
            getImage(object!)
            let imageCell = tableView.dequeueReusableCellWithIdentifier("QuestionImageCell", forIndexPath: indexPath) as! QuestionImageCell
            imageCell.questionLabel.text = question.question
            imageCell.timeLabel.text = question.createdAt?.shortTimeAgoSinceDate(NSDate())
            imageCell.usernameLabel.text = question.user?.username
            imageCell.categoryLabel.textColor = UIColor.whiteColor()
            imageCell.categoryLabel.text = question.category
            imageCell.categoryLabel.backgroundColor = colorPicker.colorChooser(question.category!)
            imageCell.postImage.clipsToBounds = true
            imageCell.postImage.image = downloadedImage
            pickedCell = imageCell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
            cell.questionLabel.text = question.question
            cell.timeLabel.text = question.createdAt?.shortTimeAgoSinceDate(NSDate())
            cell.usernameLabel.text = question.user?.username
            cell.categoryLabel.textColor = UIColor.whiteColor()
            cell.categoryLabel.text = question.category
            cell.categoryLabel.backgroundColor = colorPicker.colorChooser("Entertainment")
            pickedCell = cell
        }
        return pickedCell
    }
    //MARK: Query for location

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0) {
            let location = locations[locations.count - 1]
            currLocation = location.coordinate
            self.loadObjects()
        }
        else {
            alert("Please enable location services in settings!")
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        alert("Please enable location services in settings!")
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject? {
        var obj: PFObject? = nil
        if(indexPath.row < self.objects!.count){
            obj = self.objects![indexPath.row] as PFObject
        }
        
        return obj
    }
    
    //Limits amount of characters in post
    @objc internal func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 100;
    }
    
    override func queryForTable() -> PFQuery {
        let query = Question.query()!
        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: 5)
        }
        else {
            //Decide on how the application should react if there is no location available
            
            //IMPLEMENT LATER: IMAGE ON SCREEN SAYING CAN'T GET LOCATION
        }
        query.limit = 100;
        query.orderByDescending("createdAt")
        query.includeKey("user")
        return query
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "questionDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let obj = self.objects![indexPath!.row] as? Question
                let detail = segue.destinationViewController as! DetailViewController
                detail.question = obj
            }
        }
    }
    
    //When user posts something
    @IBAction func postPressed(sender: AnyObject) {
        let alert = SCLAlertView()
        let question = Question()
        if(selectedCategory != nil) {
            question.category = selectedCategory
        }
        else {
            alert.showError("Error", subTitle: "Please select a category")
        }
        if(writeQuestionTextView.text != "") {
            question.question = writeQuestionTextView.text
            alert.showError("Error", subTitle: "You haven't written a question!")
        }
        question.location = PFGeoPoint(latitude: currLocation!.latitude, longitude: currLocation!.longitude)
        question.user = PFUser.currentUser()
        if let image = image {
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "\(question.objectId).jpg", data: imageData) else {return}
            question.imageFile = imageFile
            question.hasImage = true
        }
        question.saveInBackground()
        self.loadObjects()
        tableView.reloadData()
        print("posted at lat: \(currLocation!.latitude), long \(currLocation!.longitude)")
        textFieldShouldReturn(writeQuestionTextView)
    }
}

extension QuestionsViewController: UITextViewDelegate {
    func alert(message: String) {
        let alert = UIAlertController(title: "We couldn't fetch your location.", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }
        alert.addAction(settings)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Turn off text field when post is pressed
    func textFieldShouldReturn(textField: UITextView!) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return true;
    }
}