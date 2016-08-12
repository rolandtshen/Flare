//
//  NewPostViewController.swift
//  Questions
//
//  Created by Roland Shen on 8/5/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import ChameleonFramework
import SCLAlertView
import Parse
import ParseUI
import SVProgressHUD
import Mixpanel
import IQKeyboardManagerSwift

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var postTextView: IQTextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var categoryButton: UIButton!
    
    var image: UIImage?
    var selectedCategory: String?
    var currLocation: CLLocationCoordinate2D?
    var reset: Bool = false
    let locationManager = CLLocationManager()
    var imagePickerController: UIImagePickerController?
    var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicView.layer.cornerRadius = profilePicView.frame.width/2
        profilePicView.clipsToBounds = true
        getProfilePic(PFUser.currentUser()!) { (image) in
            self.profilePicView.image = image
        }
        
        postTextView.sizeToFit()
        postTextView.layoutIfNeeded()
        nameLabel.text = PFUser.currentUser()?.username
        categoryButton.titleLabel?.textAlignment = NSTextAlignment.Center
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        toolbar = UIToolbar()
        toolbar.translucent = false
        toolbar.tintColor = UIColor.flatBlackColor()
        let cameraButton = UIBarButtonItem(image: UIImage(named: "MMS"), style: .Plain, target: self, action: #selector(NewPostViewController.chooseImageSource))
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Post", style: .Plain, target: self, action: #selector(NewPostViewController.uploadPost))
        
        toolbar.items = [cameraButton, space, postButton]
        toolbar.sizeToFit()
        return toolbar
    }
    
    func uploadPost() {
        let question = Question()
        var hasError = false
        let alert = SCLAlertView()
        if(selectedCategory != nil) {
            question.category = selectedCategory
        } else {
            alert.showError("Error", subTitle: "Please select a category")
            hasError = true
        }
        if(postTextView.text != "") {
            question.question = postTextView.text
        } else {
            alert.showError("Error", subTitle: "You haven't written a question!")
            hasError = true
        }
        
        question.location = PFGeoPoint(latitude: currLocation!.latitude, longitude: currLocation!.longitude)
        question.user = PFUser.currentUser()
        if let image = image {
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "\(question.objectId).jpg", data: imageData) else {return}
            question.imageFile = imageFile
            question.hasImage = true
        }
        if(hasError == false) {
            SVProgressHUD.show()
            question.saveInBackgroundWithBlock {(success, error) -> Void in
                if(error == nil) {
                    print("posted at lat: \(self.currLocation!.latitude), long \(self.currLocation!.longitude)")
                    self.image = nil
                    self.selectedCategory = nil
                    self.navigationController?.popViewControllerAnimated(true)
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccessWithStatus("Posted!")
                    Mixpanel.sharedInstance().track("Uploaded post")
                    self.postTextView.resignFirstResponder()
                }
                else {
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func pressCategoryButton(sender: AnyObject) {
        let alertView = SCLAlertView()
        
        if(postTextView.isFirstResponder()) {
            postTextView.resignFirstResponder()
        }
        
        alertView.addButton("Travel", backgroundColor: UIColor.flatRedColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Travel"
            
            self.categoryButton.backgroundColor = UIColor.flatRedColor()
            self.categoryButton.titleLabel?.text = "Travel"
        }
        
        alertView.addButton("Entertainment", backgroundColor: UIColor.flatOrangeColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Entertainment"
            
            self.categoryButton.backgroundColor = UIColor.flatYellowColor()
            self.categoryButton.titleLabel?.text = "Entertainment"
        }
        
        alertView.addButton("Meetup", backgroundColor: UIColor.flatYellowColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Meetup"
            
            self.categoryButton.backgroundColor = UIColor.flatYellowColor()
            self.categoryButton.titleLabel?.text = "Meetup"
        }
        
        alertView.addButton("Listings", backgroundColor: UIColor.flatGreenColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Listings"
            
            self.categoryButton.backgroundColor = UIColor.flatGreenColor()
            self.categoryButton.titleLabel?.text = "Listings"
        }
        
        alertView.addButton("Recommendations", backgroundColor: UIColor.flatSkyBlueColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Recommendations"
            
            self.categoryButton.backgroundColor = UIColor.flatSkyBlueColor()
            self.categoryButton.titleLabel?.text = "Recommendations"
        }
        alertView.addButton("Other", backgroundColor: UIColor.flatMagentaColor(), textColor: UIColor.whiteColor(), showDurationStatus: true) {
            self.selectedCategory = "Other"
            
            self.categoryButton.backgroundColor = UIColor.flatMagentaColor()
            self.categoryButton.titleLabel?.text = "Other"
        }
        
        alertView.showNotice("Categories", subTitle: "")
    }
    
    func getProfilePic(user: PFUser, completionHandler: (UIImage) -> Void) {
        let profile = user
        if let picture = profile.objectForKey("profilePic") {
            picture.getDataInBackgroundWithBlock({
                (imageData: NSData?, error: NSError?) -> Void in
                if (imageData != nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }

    //MARK: Image Picker Methods
    func chooseImageSource() {
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
        }
        Mixpanel.sharedInstance().track("Picked image")
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        presentViewController(imagePickerController!, animated: true, completion: nil)
    }
}

//MARK: TextView Methods
extension NewPostViewController: UITextViewDelegate {
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
}

extension NewPostViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[0]
            currLocation = location.coordinate
        } else {
            print("cant get location")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}
