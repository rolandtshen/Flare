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
}