//
//  EditProfileViewController.swift
//  Questions
//
//  Created by Roland Shen on 8/5/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManager
import Parse

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bioTextView: IQTextView!
    @IBOutlet weak var nameTextView: IQTextView!
    @IBOutlet weak var emailTextView: IQTextView!
    
    var imagePickerController: UIImagePickerController?
    var chosenProfilePic: UIImage?
    
    override func viewDidAppear(animated: Bool) {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2;
        profileImageView.clipsToBounds = true
        
        if(PFUser.currentUser()?.objectForKey("profilePic") != nil) {
            getProfilePic(PFUser.currentUser()!, completionHandler: { (image) in
                self.profileImageView.image = image
            })
        }
        if(PFUser.currentUser()?.objectForKey("bio") != nil) {
            bioTextView.text = PFUser.currentUser()?.objectForKey("bio") as! String
        }
        else {
            bioTextView.text = ""
        }
        
        nameTextView.text = PFUser.currentUser()?.objectForKey("name") as! String
        emailTextView.text = PFUser.currentUser()?.username
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
    
    func saveUsername() {
        let user = PFUser.currentUser()
        user!.username = emailTextView.text
        user?.saveInBackground()
    }
    
    func saveEmail() {
        let user = PFUser.currentUser()
        user!.email = emailTextView.text
        user?.saveInBackground()
    }
    
    func saveBio() {
        let user = PFUser.currentUser()
        user?.setObject(bioTextView.text, forKey: "bio")
        user?.saveInBackgroundWithBlock {(success, error) -> Void in
            
        }
    }
    
    func saveProfilePic(image: UIImage) {
        let user = PFUser.currentUser()
        user!["profilePic"] = PFFile(name: "sdfsdf.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
        user?.saveInBackground()
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        saveUsername()
        saveBio()
        saveEmail()
        if(chosenProfilePic != nil) {
            saveProfilePic(chosenProfilePic!)
        }
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = pickedImage
            chosenProfilePic = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        presentViewController(imagePickerController!, animated: true, completion: nil)
    }
}

