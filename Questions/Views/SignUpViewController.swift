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
import SVProgressHUD
import Mixpanel

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var fullNameField: UITextField! //username
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        
        let colors:[UIColor] = [
            UIColor(hexString: "dd2c00"),
            UIColor(hexString: "ffc107")
        ]
        signUpButton.backgroundColor = UIColor.init(gradientStyle: .leftToRight, withFrame: view.frame, andColors: colors)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func tosButton(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.rolandshen.com/orca/eula.html")!)
    }
    
    @IBAction func signUpPressed(_ sender: AnyObject) {
        let username = self.fullNameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        var hasError = false
        
        // Validate the text fields
        
        if username == "" {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a username!")
            hasError = true
        }
        
        if email == "" {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered an email!")
            hasError = true
        }
        
        if password == "" {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a password!")
            hasError = true
        }
     
        if(hasError == false) {
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = email
            SVProgressHUD.show()
            
            // Sign up the user asynchronously
            newUser.signUpInBackground(block: { (succeed, error) -> Void in
                if (error == nil) {
                    Mixpanel.sharedInstance().track("Signed up successfully")
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "Welcome to Questions!")
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                        self.present(viewController, animated: true, completion: nil)
                    })
                }
                else {
                    SVProgressHUD.dismiss()
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "Username or email are already taken")
                }
            })
        }
    }
}
