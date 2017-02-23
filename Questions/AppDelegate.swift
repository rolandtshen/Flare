
//
//  AppDelegate.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import UIKit
import Parse
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var parseLoginHelper: ParseLoginHelper!
    
    override init() {
        super.init()
        UIApplication.shared.statusBarStyle = .lightContent
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            } else  if let _ = user {
                // if login was successful, display the TabBarController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                self.window?.rootViewController!.present(tabBarController, animated: true, completion: nil)
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        application.statusBarStyle = .lightContent
        UIApplication.shared.statusBarStyle = .lightContent
        
        //initialize Parse
        let configuration = ParseClientConfiguration {
            $0.applicationId = "questionsapp"
            $0.server = "https://questionsapp.herokuapp.com/parse"
        }
        Parse.initialize(with: configuration)
        
        let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        //register subclasses
        Message.registerSubclass()
        Conversation.registerSubclass()
        Question.registerSubclass()
        Reply.registerSubclass()
        Flag.registerSubclass()
        Like.registerSubclass()
        
        //initialize Mixpanel
        Mixpanel.sharedInstance(withToken: "8393fb097d75410d96bf238e12397daf")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
        
        //determine whether or not to show login screen
        let user = PFUser.current()
        //broke here
        var startViewController: UIViewController?
        
        if (user != nil) {
            // if we have a user, set the TabBarController to be the initial view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        } else {
            // Otherwise set the LoginViewController to be the first
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = startViewController;
        self.window?.makeKeyAndVisible()
        
        application.isStatusBarHidden = false
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.channels = ["global"]
        installation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "new_message"), object: nil)
        print("push received")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
