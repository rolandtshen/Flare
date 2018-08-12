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
        NotificationCenter.default.post(name: .changeProfilePic, object: nil)
    }
}

extension Notification.Name {
    static let changeProfilePic = Notification.Name("changeProfilePic")
}
