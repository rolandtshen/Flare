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
    @IBOutlet weak var posterQuestion: UILabel!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var posterTime: UILabel!
    
    var numReplies: Int?
    var question: Question? {
        didSet {
            //nothing for now
        }
    }
    
    override func viewDidLoad() {
        originalQuestionView.layer.cornerRadius = 10
        originalQuestionView.layer.masksToBounds = true
        
        tableView.estimatedRowHeight = 125.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}