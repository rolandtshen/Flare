//
//  TabViewController.swift
//  Questions
//
//  Created by Roland Shen on 10/5/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TabViewController: UITabBarController {
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let tabVc = segue.destination as! UITabBarController
//        let navVc = tabVc.viewControllers!.first as! UINavigationController
//        let profile = navVc.viewControllers.first as! ProfileViewController
//        profile.user = PFUser.current()
//    }
}
