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

class LoginViewController: UIViewController {
 
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        
        let colors:[UIColor] = [
            UIColor(hexString: "#1ED4A5"),
            UIColor(hexString: "#22C0CF")
        ]
        signInButton.backgroundColor = UIColor.init(gradientStyle: .LeftToRight, withFrame: view.frame, andColors: colors)
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
    }
    
    @IBAction func signInPressed(sender: AnyObject) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        // Validate the text fields
        if username == nil {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a username!")
            
        } else if password == nil {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a password!")
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabBarController")
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                    
                } else {
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "\(error)")
                }
            })
        }
    }
    
    @IBAction func facebookPressed(sender: AnyObject) {
        let permissions = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
            if ((user) != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(viewController, animated: true, completion: nil)
                })
                
            } else {
                let alert = SCLAlertView()
                alert.showError("Error", subTitle: "\(error)")
            }
        })
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