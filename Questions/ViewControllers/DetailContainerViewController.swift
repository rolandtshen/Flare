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

class DetailContainerViewController: UIViewController {
    
    var question: Question?
    var tableView: DetailViewController?
    
    @IBOutlet weak var replyTextView: UITextView!
    
    override func viewDidLoad() {
    }
    
    func textViewShouldReturn(textView: UITextView!) -> Bool {
        textView.resignFirstResponder()
        textView.text = ""
        return true;
    }
    
    @IBAction func sendPressed(sender: AnyObject) {
        let reply = Reply()
        if(replyTextView.text != "") {
            reply.reply = replyTextView.text
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
        textViewShouldReturn(replyTextView)
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