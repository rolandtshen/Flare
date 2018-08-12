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
import Mixpanel
import SVProgressHUD
import SCLAlertView

class LoginViewController: UIViewController {
 
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    //@IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colors:[UIColor] = [
            UIColor(hexString: "0ae7f2"),
            UIColor(hexString: "0b9de7")
        ]
        signInButton.backgroundColor = UIColor.init(gradientStyle: .leftToRight, withFrame: view.frame, andColors: colors)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func keyboardWillShow(notification:NSNotification){
//        
//        var userInfo = notification.userInfo!
//        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
//        
//        var contentInset:UIEdgeInsets = self.scrollView.contentInset
//        contentInset.bottom = keyboardFrame.size.height
//        self.scrollView.contentInset = contentInset
//    }
//    
//    func keyboardWillHide(notification:NSNotification){
//        
//        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
//        self.scrollView.contentInset = contentInset
//    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func signInPressed(_ sender: AnyObject) {
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
            PFUser.logInWithUsername(inBackground: username!, password: password!, block: { (user, error) -> Void in
                if ((user) != nil) {
                    SVProgressHUD.dismiss()
                    let installation = PFInstallation.current()
                    installation?.setObject(PFUser.current()!, forKey: "user")
                    installation?.saveInBackground()
                    Mixpanel.sharedInstance().track("Logged in successfully")
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                        self.present(viewController, animated: true, completion: nil)
                    })
                    
                } else {
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "Your login credentials were not correct.")
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
}

class borderlessTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
