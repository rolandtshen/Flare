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
import Eureka

class MyFormViewController: FormViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++
        Section("@\((PFUser.current()?.username!)!)") {
            var header = HeaderFooterView<ChangeProfilePicView>(.nibFile(name: "ChangeProfilePicView", bundle: nil))
            header.onSetupView = { (view, section) -> () in
                view.setProfilePic()
                self.getProfilePic(PFUser.current()!, completionHandler: { (image) in
                    view.profileView.image = image
                })
                if let profilePic = view.profilePic {
                    self.getProfilePic(PFUser.current()!, completionHandler: { (image) in
                        view.profileView.image = image
                    })
                }
                view.profileView.layer.cornerRadius = (view.profileView.frame.width)/2
                view.profileView.clipsToBounds = true
            }
            $0.header = header
            }

            <<< NameRow("nameRow") { row in
                row.title = "👨‍🏭"
                row.placeholder = "Name"
                }
                .cellSetup { cell, row in
                    self.getUsername({ (name) in
                        cell.textField.text = name
                        row.value = name
                    })
                }
                .cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    row.value = cell.textField.text
            }
            
            <<< EmailRow("emailRow") { row in
                row.title = "✉️"
                row.placeholder = "Email"
                }
                .cellSetup { cell, row in
                    self.getEmail({ (email) in
                        row.value = email
                        cell.textField.text = email
                    })
                }
                .cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    row.value = cell.textField.text
            }
            
            <<< TextRow("textRow") { row in
                row.title = "📝"
                row.placeholder = "Biography"
                }
                .cellSetup { cell, row in
                    self.getBio({ (bio) in
                        row.value = bio
                        cell.textField.text = bio
                    })
                }
                .cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    row.value = cell.textField.text
            }
    }
    
    @IBAction func savePressed(_ sender: AnyObject) {
        let nameRow: NameRow? = form.rowBy(tag: "nameRow")
        let nameValue = nameRow?.value
        let emailRow: EmailRow? = form.rowBy(tag: "emailRow")
        let emailValue = emailRow?.value
        let bioRow: TextRow? = form.rowBy(tag: "textRow")
        let bioValue = bioRow?.value
        let user = PFUser.current()
        user!.username = nameValue
        user!.email = emailValue
        user!["bio"] = bioValue
//        if let image = chosenProfilePic {
//            user!["profilePic"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
//        }
        SVProgressHUD.show()
        user?.saveInBackground(block: { (success, error) in
            if(error == nil) {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        })
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
}
