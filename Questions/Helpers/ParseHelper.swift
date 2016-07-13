////
////  ParseHelper.swift
////  Questions
////
////  Created by Roland Shen on 7/12/16.
////  Copyright © 2016 Roland Shen. All rights reserved.
////
//
//import Foundation
//import Parse
//
//class ParseHelper {
//    
//    // Like Relation
//    static let ParseLikeClass         = "Like"
//    static let ParseLikeToPost        = "toPost"
//    static let ParseLikeFromUser      = "fromUser"
//    
//    // Post Relation
//    static let ParsePostUser          = "user"
//    static let ParsePostCreatedAt     = "createdAt"
//    
//    // Flagged Content Relation
//    static let ParseFlaggedContentClass    = "FlaggedContent"
//    static let ParseFlaggedContentFromUser = "fromUser"
//    static let ParseFlaggedContentToPost   = "toPost"
//    
//    // User Relation
//    static let ParseUserUsername      = "username"
//    
//    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
//        
//        let postsFromThisUser = Question.query()
//        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
//        
//        // i need to query people in the same city location together (location instead of postsfromfollowedusers)
//        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
//        
//        query.includeKey(ParsePostUser)
//        query.orderByDescending(ParsePostCreatedAt)
//        query.skip = range.startIndex
//        query.limit = range.endIndex - range.startIndex
//        query.findObjectsInBackgroundWithBlock(completionBlock)
//    }
//    
//    static func likePost(user: PFUser?, question: Question) {
//        let likeObject = PFObject(className: ParseLikeClass)
//        likeObject[ParseLikeFromUser] = user
//        likeObject[ParseLikeToPost] = post
//        likeObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
//    }
//    
//    static func unlikePost(user: PFUser, question: Question) {
//        let query = PFQuery(className: ParseLikeClass)
//        query.whereKey(ParseLikeFromUser, equalTo: user)
//        query.whereKey(ParseLikeToPost, equalTo: post)
//        
//        query.findObjectsInBackgroundWithBlock {(results: [PFObject]?, error: NSError?) -> Void in
//            if let results = results {
//                for like in results {
//                    like.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
//                }
//            }
//        }
//    }
//    
//    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
//        let query = PFQuery(className: ParseLikeClass)
//        query.whereKey(ParseLikeToPost, equalTo: post) //where do you get the params
//        query.includeKey(ParseLikeFromUser) //how does this know to connect it to the toPost?
//        query.findObjectsInBackgroundWithBlock(completionBlock)
//    }
//    // MARK: Following
//    
//    /**
//     Fetches all users that the provided user is following.
//     
//     :param: user The user whose followees you want to retrieve
//     :param: completionBlock The completion block that is called when the query completes
//     */
//    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFQueryArrayResultBlock) {
//        let query = PFQuery(className: ParseFollowClass)
//        
//        query.whereKey(ParseFollowFromUser, equalTo:user)
//        query.findObjectsInBackgroundWithBlock(completionBlock)
//    }
//    
//    // MARK: Users
//    
//    /**
//     Fetch all users, except the one that's currently signed in.
//     Limits the amount of users returned to 20.
//     
//     :param: completionBlock The completion block that is called when the query completes
//     
//     :returns: The generated PFQuery
//     */
//    
//    static func allUsers(completionBlock: PFQueryArrayResultBlock) -> PFQuery {
//        let query = PFUser.query()!
//        // exclude the current user
//        query.whereKey(ParseHelper.ParseUserUsername,
//                       notEqualTo: PFUser.currentUser()!.username!)
//        query.orderByAscending(ParseHelper.ParseUserUsername)
//        query.limit = 20
//        
//        query.findObjectsInBackgroundWithBlock(completionBlock)
//        
//        return query
//    }
//    
//    /**
//     Fetch users whose usernames match the provided search term.
//     
//     :param: searchText The text that should be used to search for users
//     :param: completionBlock The completion block that is called when the query completes
//     
//     :returns: The generated PFQuery
//     */
//    static func searchUsers(searchText: String, completionBlock: PFQueryArrayResultBlock) -> PFQuery {
//        /*
//         NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
//         Regex can be slow on large datasets. For large amount of data it's better to store
//         lowercased username in a separate column and perform a regular string compare.
//         */
//        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
//                                             matchesRegex: searchText, modifiers: "i")
//        
//        query.whereKey(ParseHelper.ParseUserUsername,
//                       notEqualTo: PFUser.currentUser()!.username!)
//        
//        query.orderByAscending(ParseHelper.ParseUserUsername)
//        query.limit = 20
//        
//        query.findObjectsInBackgroundWithBlock(completionBlock)
//        
//        return query
//    }
//}
//
//extension PFObject {
//    
//    public override func isEqual(object: AnyObject?) -> Bool {
//        if (object as? PFObject)?.objectId == self.objectId {
//            return true
//        }
//        else {
//            return super.isEqual(object)
//        }
//    }
//}
