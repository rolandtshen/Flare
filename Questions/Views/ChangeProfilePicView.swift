//
//  ChangeProfilePicView.swift
//  Questions
//
//  Created by Roland Shen on 2/20/17.
//  Copyright © 2017 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ChangeProfilePicView: UIView, UIImagePickerControllerDelegate {
    
    var imagePickerController: UIImagePickerController?
    //this image is the currentuser's image
    var profilePic: UIImage?
    
    func setProfilePic() {
        if let userPicture = PFUser.current()?.object(forKey: "profilePic") as? PFFile {
            userPicture.getDataInBackground(block: { (data, error) -> Void in
                if (error == nil) {
                    self.profilePic = UIImage(data: data!)
                }
            })
        }
        else {
            profilePic = UIImage(named: "default")!
        }
    }
    
    //in headerview, access this variable and put all the imagepickercontroller methods in this class
    
    @IBOutlet weak var profileView: UIImageView!
    
    @IBAction func changePicture(_ sender: Any) {
        chooseImageSource()
    }
    
    func chooseImageSource() {
        // Allow user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .default) { (action) in
            self.showImagePickerController(sourceType: UIImagePickerControllerSourceType.photoLibrary)
        }
        
        alertController.addAction(photoLibraryAction)
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
                self.showImagePickerController(sourceType: UIImagePickerControllerSourceType.camera)
            }
            alertController.addAction(cameraAction)
        }
        alertController.present(alertController, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController?.sourceType = sourceType
       // imagePickerController?.delegate = self
        
        imagePickerController?.present(imagePickerController!, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePic = pickedImage
        }
    
        imagePickerController?.dismiss(animated: true, completion: nil)
    }
}
