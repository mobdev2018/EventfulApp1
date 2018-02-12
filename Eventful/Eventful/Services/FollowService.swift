//
//  FollowService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/17/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  FirebaseDatabase

struct FollowService {
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        // 1
        //We create a dictionary to update multiple locations at the same time. We set the appropriate key-value for our followers and following.
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                          "following/\(currentUID)/\(user.uid)" : true]
        
        // 2
        //We write our new relationship to Firebase.
        let ref = Database.database().reference()
        // creating another ref to followers where we check user have followed other user any time
        let reference = ref.child("followers/\(user.uid)/\(currentUID)")
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            ref.updateChildValues(followData) { (error, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                // 3
                // Here we are sending push to user whom we've started following
                
                //4
                // If snapshot is returns null => user have never followed the other user and will push notification to him
                
                //5
                // If User/You have ever followed/unfollowed other user ever and snapshot will return a boolean value and in that app will not send push notification
                if (!snapshot.exists()){
                    self.sendFollowNotificationToUser(otherUser: user)
                }
                // 6
                //We return whether the update was successful based on whether there was an error.
                success(error == nil)
            }
        })
    }
    
    private static func sendFollowNotificationToUser(otherUser : User){
        
        let notification = Notifications.init(eventKey: "", repliedTo: otherUser.uid, repliedBy: User.current.uid, content: User.current.username! + " has started following you", commentId: "", profilePic: User.current.profilePic!, type: "follow")
        // sending push notification to user
        ChatService.sendNotification(notification)
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
        // http://stackoverflow.com/questions/38462074/using-updatechildvalues-to-delete-from-firebase
        /*let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]*/
        
        // Changing to false, to prevent unwanted follow notifications to user
        let followData = ["followers/\(user.uid)/\(currentUID)" : false,
                          "following/\(currentUID)/\(user.uid)" : false]
        
        let ref = Database.database().reference()
        ref.updateChildValues(followData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            success(error == nil)
        }
    }
    
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("followers").child(user.uid)
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    
    
}

