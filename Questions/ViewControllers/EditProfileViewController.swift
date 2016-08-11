//
//  EditProfileViewController.swift
//  Questions
//
//  Created by Roland Shen on 8/5/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import Parse
import SCLAlertView
import SVProgressHUD

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bioTextView: IQTextView!
    @IBOutlet weak var nameTextView: IQTextView!
    @IBOutlet weak var emailTextView: IQTextView!
    
    var imagePickerController: UIImagePickerController?
    var chosenProfilePic: UIImage?
    
    override func viewDidLoad() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2;
        profileImageView.clipsToBounds = true
        
        nameTextView.text = PFUser.currentUser()?.username
        emailTextView.text = PFUser.currentUser()?.email
        
        getProfilePic(PFUser.currentUser()!) { (profilePic) in
            self.profileImageView.image = profilePic
        }
        
        getBio { (bio) in
            self.bioTextView.text = bio
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        let user = PFUser.currentUser()
        user!.username = emailTextView.text
        user!.email = emailTextView.text
        user!["bio"] = bioTextView.text
        if let image = chosenProfilePic {
            user!["profilePic"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
        }
        SVProgressHUD.show()
        user?.saveInBackgroundWithBlock({ (success, error) in
            if(error == nil) {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
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
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = pickedImage
            chosenProfilePic = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Downloads
    
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
    
    func getBio(completionHandler: (String) -> Void) {
        let query = PFUser.query()
        query!.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query!.getFirstObjectInBackgroundWithBlock { (object, error) in
            if(error == nil) {
                if(object!["bio"] != nil) {
                    completionHandler(object!["bio"] as! String)
                }
                else {
                    completionHandler("")
                }
            }
        }
    }
    
    @IBAction func changePhoto(sender: AnyObject) {
        chooseImageSource()
    }
}

