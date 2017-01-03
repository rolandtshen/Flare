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
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.LightContent
    }
}
