//
//  ChatService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  FirebaseDatabase
import Firebase
import FirebaseAuth


class ChatService {
    static func sendMessage(_ message: Comments, eventKey: String,success: ((Bool) -> Void)? = nil) {
        
        var multiUpdateValue = [String : Any]()

        let messagesRef = Database.database().reference().child("comments").child(eventKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["Comments/\(eventKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
    
    static func sendNotification(_ notification: Notifications, success: ((Bool) -> Void)? = nil) {
        
        var multiUpdateValue = [String : Any]()
        
        let messagesRef = Database.database().reference().child("notifcations").child(notification.repliedTo).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["Notifications/\(notification.repliedTo)/\(messageKey)"] = notification.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            success?(true)
        })
    }
    
    static func flag(_ comment: CommentGrabbed) {
        // 1
        guard let commentKey = comment.commentID else { return }
        
        // 2
        let flaggedPostRef = Database.database().reference().child("flaggedComments").child(commentKey)
        
        // 3
        let flaggedDict = ["image_url": comment.user?.profilePic,
                           "poster_uid": comment.uid,
                           "reporter_uid": User.current.uid]
        
        // 4
        flaggedPostRef.updateChildValues(flaggedDict as Any as! [AnyHashable : Any])
        
        // 5
        let flagCountRef = flaggedPostRef.child("flag_count")
        flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            
            mutableData.value = currentCount + 1
            
            return TransactionResult.success(withValue: mutableData)
        })
    }
    
    static func deleteComment(_ comment: CommentGrabbed, _ eventKey: String){
        //1
        guard let commentkey = comment.commentID else {
            return
        }
        
      //  print(commentkey)
       // print(eventKey)
        
        let commentData = ["Comments/\(eventKey)/\(commentkey)": NSNull()]
        
        Database.database().reference().updateChildValues(commentData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
        }
        
    }
    
    static func observeMessages(forChatKey eventKey: String, completion: @escaping (DatabaseReference, Comments?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child(eventKey)
        return messagesRef.observe(.childAdded, with: { snapshot in
            guard let message = Comments(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            
            completion(messagesRef, message)
        })
    }
}
