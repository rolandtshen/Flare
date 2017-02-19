//
//  TabViewController.swift
//  Questions
//
//  Created by Roland Shen on 10/5/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation

class TabViewController: UITabBarController{
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}
