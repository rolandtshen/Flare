//
//  DetailContainerViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/25/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SVProgressHUD

class DetailContainerViewController: UIViewController {
    
    var question: Question?
    var tableView: DetailViewController?
    
    @IBOutlet weak var flagButton: UIBarButtonItem!
    @IBOutlet weak var replyTextField: UITextField!
    
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        if(question?.user == PFUser.currentUser()) {
            flagButton = nil
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return true;
    }

    func showFlagActionSheetForPost() {
        let alertController = UIAlertController(title: nil, message: "Choose an action", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let blockAction = UIAlertAction(title: "Block", style: .Destructive) { (action) in
            let block = Block()
            block.fromUser = PFUser.currentUser()
            block.toUser = self.question?.user
            SVProgressHUD.show()
            block.saveInBackgroundWithBlock({(success, error) in
                SVProgressHUD.dismiss()
            })
        }
        
        alertController.addAction(blockAction)
        
        let flagAction = UIAlertAction(title: "Flag", style: .Destructive) { (action) in
            let flag = Flag()
            flag.fromUser = PFUser.currentUser()
            flag.toPost = self.question
            SVProgressHUD.show()
            flag.saveInBackgroundWithBlock({ (success, error) in
                SVProgressHUD.dismiss()
            })
        }
        
        alertController.addAction(flagAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendPressed(sender: AnyObject) {
        let reply = Reply()
        if(replyTextField.text != "") {
            reply.reply = replyTextField.text
            reply.fromUser = PFUser.currentUser()
            reply.toPost = question!
            reply.saveInBackgroundWithBlock{ (success, error) -> Void in
                if(error == nil) {
                    self.tableView?.loadObjects()
                }
            }
        }
        else {
            ErrorHandling.ErrorDefaultMessage
        }
        textFieldShouldReturn(replyTextField)
    }

    @IBAction func flagPressed(sender: AnyObject) {
        showFlagActionSheetForPost()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "repliesTableView" {
            let detail = segue.destinationViewController as! DetailViewController
                detail.question = question
                tableView = detail
            }
        }
    }
}