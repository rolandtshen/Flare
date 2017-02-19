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
    
    @IBOutlet weak var replyTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var flagButton: UIBarButtonItem!
    @IBOutlet weak var replyTextField: UITextField!
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 20.0)!, NSForegroundColorAttributeName: UIColor.white]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        if(question?.user == PFUser.current()) {
            flagButton = nil
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return true;
    }

    func showFlagActionSheetForPost() {
        let alertController = UIAlertController(title: nil, message: "Choose an action", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let blockAction = UIAlertAction(title: "Block", style: .destructive) { (action) in
            let block = Block()
            block.fromUser = PFUser.current()
            block.toUser = self.question?.user
            SVProgressHUD.show()
            block.saveInBackground(block: {(success, error) in
                SVProgressHUD.dismiss()
            })
        }
        
        alertController.addAction(blockAction)
        
        let flagAction = UIAlertAction(title: "Flag", style: .destructive) { (action) in
            let flag = Flag()
            flag.fromUser = PFUser.current()
            flag.toPost = self.question
            SVProgressHUD.show()
            flag.saveInBackground(block: { (success, error) in
                SVProgressHUD.dismiss()
            })
        }
        
        alertController.addAction(flagAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        let reply = Reply()
        if(replyTextField.text != "") {
            reply.reply = replyTextField.text
            reply.fromUser = PFUser.current()
            reply.toPost = question!
            reply.saveInBackground{ (success, error) -> Void in
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

    @IBAction func flagPressed(_ sender: AnyObject) {
        showFlagActionSheetForPost()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "repliesTableView" {
            let detail = segue.destination as! DetailViewController
                detail.question = question
                tableView = detail
            }
        }
    }
}
