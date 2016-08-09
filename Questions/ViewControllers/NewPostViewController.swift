//
//  NewPostViewController.swift
//  Questions
//
//  Created by Roland Shen on 8/5/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import IQKeyboardManager
import ChameleonFramework
import SCLAlertView
import Parse

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var postTextView: IQTextView!
    
    var image: UIImage?
    var selectedCategory: String?
    var currLocation: CLLocationCoordinate2D?
    var reset: Bool = false
    let locationManager = CLLocationManager()
    var imagePickerController: UIImagePickerController?
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postTextView.sizeToFit()
        postTextView.layoutIfNeeded()
        
        // input accessory view
        let toolbar = UIToolbar()
        toolbar.translucent = false
        toolbar.tintColor = UIColor.flatBlackColor()
        let cameraButton = UIBarButtonItem(image: UIImage(named: "camera"), style: .Plain, target: self, action: #selector(imageTapped(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Post", style: .Plain, target: self, action: nil)
        toolbar.items = [cameraButton, space, postButton]
        toolbar.sizeToFit()
        postTextView.inputAccessoryView = toolbar
    }

    
    func uploadPost(completionHandler: () -> Void) {
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
            question.saveInBackgroundWithBlock {(success, error) -> Void in
                if(error == nil) {
                    print("posted at lat: \(self.currLocation!.latitude), long \(self.currLocation!.longitude)")
                    self.textFieldShouldReturn(self.postTextView)
                    self.image = nil
                    self.selectedCategory = nil
                }
            }
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
    
    func textFieldShouldReturn(textField: UITextView!) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return true;
    }
}
