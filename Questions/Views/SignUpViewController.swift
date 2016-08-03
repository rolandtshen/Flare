//
//  SignUpViewController.swift
//  Questions
//
//  Created by Roland Shen on 8/3/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import Parse
import SCLAlertView

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        
        let colors:[UIColor] = [
            UIColor(hexString: "#1ED4A5"),
            UIColor(hexString: "#22C0CF")
        ]
        signUpButton.backgroundColor = UIColor.init(gradientStyle: .LeftToRight, withFrame: view.frame, andColors: colors)
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        let name = self.fullNameField.text
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        
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
            
            let newUser = PFUser()
        
            newUser.setObject(name!, forKey: "name")
            newUser.username = username
            newUser.password = password
            newUser.email = email
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                spinner.stopAnimating()
                if (error == nil) {
                    let alert = SCLAlertView()
                    alert.showSuccess("Success", subTitle: "Welcome to Questions!")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabBarController")
                        self.presentViewController(viewController, animated: true, completion: nil)
                    })
                }
                else {
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "Username or email are already taken")
                }
            })
        }
    }
}