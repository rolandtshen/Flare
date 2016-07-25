//
//  DetailContainerViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/25/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit

class DetailContainerViewController: UIViewController {
    
    var question: Question?
    
    @IBOutlet weak var replyTextView: UITextView!
    
    @IBAction func sendPressed(sender: AnyObject) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "repliesTableView" {
            let detail = segue.destinationViewController as! DetailViewController
                detail.question = question
            }
        }
    }
}