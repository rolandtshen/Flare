//
//  LoginViewController.swift
//  Questions
//
//  Created by Roland Shen on 8/3/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import Parse
import SCLAlertView
import ParseFacebookUtilsV4
import FBSDKLoginKit
import FBSDKCoreKit
import SVProgressHUD

class LoginViewController: UIViewController {
 
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colors:[UIColor] = [
            UIColor(hexString: "#1ED4A5"),
            UIColor(hexString: "#22C0CF")
        ]
        signInButton.backgroundColor = UIColor.init(gradientStyle: .LeftToRight, withFrame: view.frame, andColors: colors)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
    }
    
    @IBAction func signInPressed(sender: AnyObject) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        var hasError = false
        
        // Validate the text fields
        if username == "" {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a username!")
            hasError = true
            
        }
        if password == "" {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a password!")
            hasError = true
        }
        
        if(hasError == false) {
            SVProgressHUD.show()
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                if ((user) != nil) {
                    SVProgressHUD.dismiss()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabBarController")
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                    
                } else {
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "\(error)")
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Facebook login isn't ready yet!")
//        let permissions = ["public_profile", "email", "user_friends"]
//        
//        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
//            if ((user) != nil) {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabBarController")
//                    self.presentViewController(viewController, animated: true, completion: nil)
//                })
//                
//            } else {
//                let alert = SCLAlertView()
//                alert.showError("Error", subTitle: "\(error)")
//            }
//        })
    }
}

class borderlessTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}