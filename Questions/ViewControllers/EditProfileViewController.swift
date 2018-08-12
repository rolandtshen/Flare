//
//  EditProfileViewController.swift
//  Questions
//
//  Created by Roland Shen on 8/5/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//
import Foundation
import UIKit
import Parse
import SVProgressHUD

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var emailTextView: UITextView!
    
    var imagePickerController: UIImagePickerController?
    var chosenProfilePic: UIImage?
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func viewDidLoad() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        getUsername { (username) in
            self.nameTextView.text = username
        }
        
        getEmail { (email) in
            self.emailTextView.text = email
        }
        
        getProfilePic(PFUser.current()!) { (profilePic) in
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
    
    @IBAction func savePressed(_ sender: AnyObject) {
        let user = PFUser.current()
        user!.username = nameTextView.text
        user!.email = emailTextView.text
        user!["bio"] = bioTextView.text
        if let image = chosenProfilePic {
            user!["profilePic"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
        }
        SVProgressHUD.show()
        user?.saveInBackground(block: { (success, error) in
            if(error == nil) {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    func chooseImageSource() {
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
    
    func showImagePickerController(_ sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        present(imagePickerController!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = pickedImage
            chosenProfilePic = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Downloads
    
    func getProfilePic(_ user: PFUser, completionHandler: @escaping (UIImage) -> Void) {
        let profile = user
        if let picture = profile.object(forKey: "profilePic") {
            (picture as AnyObject).getDataInBackground(block: {
                (imageData, error) -> Void in
                if (imageData != nil) {
                    completionHandler(UIImage(data: imageData!)!)
                }
            })
        }
    }
    
    func getUsername(_ completionHandler: @escaping (String) -> Void) {
        PFUser.current()?.fetchInBackground { user, error in
            completionHandler((PFUser.current()?.username)!)
        }
    }
    
    func getEmail(_ completionHandler: @escaping (String) -> Void) {
        PFUser.current()?.fetchInBackground { user, error in
            completionHandler((PFUser.current()?.email)!)
        }
    }
    
    func getBio(_ completionHandler: @escaping (String) -> Void) {
        PFUser.current()?.fetchInBackground { user, error in
            if(user!["bio"] != nil) {
                completionHandler(user!["bio"] as! String)
            }
            else {
                completionHandler("You don't have a bio!")
            }
        }
    }
    
    @IBAction func changePhoto(_ sender: AnyObject) {
        chooseImageSource()
    }
}
