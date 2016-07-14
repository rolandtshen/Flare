//
//  DetailViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/13/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var originalQuestionView: UIView!
    @IBOutlet weak var posterPicture: UIImageView!
    @IBOutlet weak var posterQuestion: UILabel!
    @IBOutlet weak var posterName: UILabel!
    
    var question: Question? {
        didSet {
            //nothing for now
        }
    }
    
    override func viewDidLoad() {
        originalQuestionView.layer.cornerRadius = 10
        originalQuestionView.layer.masksToBounds = true
    }

//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
//        let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
//        let question = PFObject(className: "Post")
//        cell.questionLabel.text = question.valueForKey("question") as? String
//        cell.timeLabel.text = question.valueForKey("createdAt") as? String
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.backgroundColor = UIColor.clearColor()
//    }

}