//
//  QuestionsViewController.swift
//  Questions
//
//  Created by Roland Shen on 7/11/16.
//  Copyright © 2016 Roland Shen. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import ChameleonFramework
import Parse
import ParseUI

class QuestionsViewController: PFQueryTableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var writeQuestionPic: UIImageView!
    @IBOutlet weak var writeQuestionTextView: UITextView!
    
    var questions: [Question]?
    var currLocation: CLLocationCoordinate2D?
    var reset: Bool = false
    let locationManager = CLLocationManager()
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.flatWhiteColor()
        tableView.estimatedRowHeight = 125.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 5
        
        self.writeQuestionTextView.selectedRange = NSMakeRange(0, 0);
        self.writeQuestionTextView.becomeFirstResponder()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        tableView.reloadData()
    }
    
    //MARK: Empty Data Set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "There haven't been any questions posted near you."
        let changes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        
        return NSAttributedString(string: str, attributes: changes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Be the first!"
        let attrs = [NSForegroundColorAttributeName : UIColor.blackColor()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ic_question_answer")
    }

    //MARK: Table View Methods
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
        cell.questionLabel.text = object!["question"] as? String
        cell.timeLabel.text = object!.createdAt //fill in with datetools
        return cell
    }
    
    //MARK: Universal Private Methods
    //Alert method
    private func alert(message : String) {
        let alert = UIAlertController(title: "Oops something went wrong.", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }
        alert.addAction(settings)
        alert.addAction(action)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Query for location
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[locations.count - 1]
            currLocation = location.coordinate
            self.loadObjects()
        } else {
            alert("Couldn't update location")
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        alert("Cannot fetch your location")
        print("DIDN'T GET LOCATION")
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject? {
        var obj: PFObject? = nil
        if(indexPath.row < self.objects!.count){
            obj = self.objects![indexPath.row] as PFObject
        }
        
        return obj
    }
    
    //Limits amount of characters in post
    private func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 100;
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Post")
        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: 10)
            query.limit = 100;
            query.orderByDescending("createdAt")
            print("location found")
        }
        else {
            //Decide on how the application should react if there is no location available
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: 0, longitude: 0), withinMiles: 10)
            query.limit = 100;
            query.orderByDescending("createdAt")
            print("no location")
        }
        return query
    }
    
      //MARK: UPVOTE/DOWNVOTES
//    @IBAction func topButton(sender: AnyObject) {
//        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
//        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
//        let object = objectAtIndexPath(hitIndex)
//        object.incrementKey("count")
//        object.saveInBackground()
//        self.tableView.reloadData()
//        NSLog("Top Index Path \(hitIndex?.row)")
//    }
//    
//    @IBAction func bottomButton(sender: AnyObject) {
//        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
//        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
//        let object = objectAtIndexPath(hitIndex)
//        object.incrementKey("count", byAmount: -1)
//        object.saveInBackground()
//        self.tableView.reloadData()
//        NSLog("Bottom Index Path \(hitIndex?.row)")
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "questionDetail" {
                print("Cell tapped")
//                let indexPath = tableView.indexPathForSelectedRow!
//                let question = questions![indexPath.row]
//                let displayQuestion = segue.destinationViewController as! DetailViewController
//                displayQuestion.question = question
            }
        }
    }
    
    func getStringFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy, H:mm"
        return dateFormatter.stringFromDate(date) // yourDate is your parse date
    }
    
    //When user posts something
    @IBAction func postPressed(sender: AnyObject) {
        let question = Question(category: "Category", question: writeQuestionTextView.text, location: currLocation!)
        question.uploadPost()
        self.loadObjects()
    }
}

