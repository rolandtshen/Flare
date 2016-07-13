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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.flatWhiteColor()
        tableView.estimatedRowHeight = 125.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
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
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionCell
        cell.questionLabel.text = "questionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestionquestion"
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
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
    
    //Limits amount of characters in post
    private func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 100;
    }
    
    @IBAction func postPressed(sender: AnyObject) {
        
    }
    
    //MARK: Query for location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        alert("Cannot fetch your location")
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Post")
        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: 10)
            query.limit = 200;
            query.orderByDescending("createdAt")
        }
        else {
            // Decide on how the application should react if there is no location available
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: 0, longitude: 0), withinMiles: 10)
            query.limit = 200;
            query.orderByDescending("createdAt")
        }
        
        return query
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[0]
            print(location.coordinate)
            currLocation = location.coordinate
        } 
        else {
            alert("There was an error fetching your location.")
        }
    }
    

    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject? {
        var obj: PFObject? = nil
        if(indexPath.row < self.objects!.count){
            obj = self.objects![indexPath.row] as PFObject
        }
        
        return obj
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
//    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "questionDetail" {
                print("Cell tapped")
                let indexPath = tableView.indexPathForSelectedRow!
                let question = questions![indexPath.row]
                let displayQuestion = segue.destinationViewController as! DetailViewController
                displayQuestion.question = question
            }
        }
    }
}


