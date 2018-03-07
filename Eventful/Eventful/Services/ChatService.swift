//
//  ChatService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseAuth


class ChatService {
    static func fetchComments(forChatKey eventKey: String,currentPostCount: Int,lastKey: String,isFinishedPaging:Bool, completion: @escaping (DatabaseReference, [CommentGrabbed],Bool) -> Void) -> DatabaseHandle {
        print(currentPostCount)
        var isFinishedPagingTemp = isFinishedPaging
        var currentCommentsArray = [CommentGrabbed]()
        var currentComment: CommentGrabbed!
        
        let commentRef = Database.database().reference().child("Comments").child(eventKey)
        var query = commentRef.queryOrderedByKey()
        if currentPostCount > 0 {
            print(lastKey)
            query = query.queryStarting(atValue: lastKey)
        }
       
        return  query.queryLimited(toFirst: 10).observe(.value, with: { (commentSnapshot) in
            guard var allComments = commentSnapshot.children.allObjects as? [DataSnapshot] else {
                return completion(commentRef, [],true)
            }

            if currentPostCount > 0 {
                allComments.removeFirst()
            }
            
            if allComments.count < 1 {
                isFinishedPagingTemp = true
                return completion(commentRef,[],true)
            }
            
            for comments in allComments {
                currentComment = CommentGrabbed(snapshot: comments)
                print(currentComment.key)
                currentCommentsArray.append(currentComment)
                print(currentComment)
            }
            
            if currentCommentsArray.count == allComments.count && !isFinishedPagingTemp {
                completion(commentRef,currentCommentsArray,false)
            }else{
                return completion(commentRef,[],true)
            }
            
        }, withCancel: { (err) in
                        print("Couldn't find comments in DB", err)
        })
        
    }
    
    
    static func sendMessage(_ message: CommentGrabbed, eventKey: String,success: ((Bool) -> Void)? = nil) {
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
        
        let messagesRef = Database.database().reference().child("notifcations").child(notification.repliedTo!).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["Notifications/\(notification.repliedTo!)/\(messageKey)"] = notification.dictValue
        
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
        let flaggedDict = ["image_url": comment.sender.profilePic,
                           "poster_uid": comment.sender.uid,
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
        guard let commentkey = comment.key else {
            return
        }
        
        //print(commentkey)
        //print(eventKey)
        
        let commentData = ["Comments/\(eventKey)/\(commentkey)": NSNull()]
        
        Database.database().reference().updateChildValues(commentData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
        }
        
    }
    //will support real time data syncing of comments
    static func observeMessages(forChatKey eventKey: String, completion: @escaping (DatabaseReference, CommentGrabbed?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("Comments").child(eventKey)
        return messagesRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: Date().timeIntervalSince1970).observe(.childAdded, with: { snapshot in
            guard let message = CommentGrabbed(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            completion(messagesRef, message)
        })
    }
}
