//
//  Notification.swift
//  Eventful
//
//  Created by Shawn Miller on 2/24/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import  IGListKit


class Notifications: NSObject {
    
    var content : String
    var creationDate : Double = 0
    var timeStamp : Date?
    var eventKey : String?
    var key : String?
    var followee : String?
    var follower : String?
    var repliedTo : String?
    var repliedBy : String?
    var commentId : String?
    var profilePic : String?
    var notiType: String?
    
    //init for comment notif
    init(eventKey: String, repliedTo: String, repliedBy: String, content: String, commentId: String, profilePic : String, type: String) {
        self.content = content
        self.creationDate = Date().timeIntervalSince1970
        self.repliedTo = repliedTo
        self.repliedBy = repliedBy
        self.eventKey = eventKey
        self.commentId = commentId
        self.profilePic = profilePic
        self.notiType = type
    }
    //init for follow notif
    init( followee: String, follower: String, content: String,profilePic : String, type: String) {
        self.content = content
        self.creationDate = Date().timeIntervalSince1970
        self.followee = followee
        self.follower = follower
        self.profilePic = profilePic
        self.notiType = type
    }
    
    //snapshot for comment notif
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let eventKey = dict["eventKey"] as? String,
            let repliedBy = dict["repliedBy"] as? String,
            let repliedTo = dict["repliedTo"] as? String,
            let commentId = dict["commentId"] as? String,
            let profilePic = dict["profilePic"] as? String,
            let notiType = dict["notiType"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.repliedBy = repliedBy
        self.repliedTo = repliedTo
        self.eventKey = eventKey
        self.commentId = commentId
        self.profilePic = profilePic
        self.notiType = notiType
    }
    
    //snapshot for follow notif
    init?(followSnapshot: DataSnapshot) {
        guard let dict = followSnapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let follower = dict["follower"] as? String,
            let followee = dict["followee"] as? String,
            let profilePic = dict["profilePic"] as? String,
            let notiType = dict["notiType"] as? String
            else { return nil }
        
        self.key = followSnapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.followee = followee
        self.follower = follower
        self.profilePic = profilePic
        self.notiType = notiType
    }
    
    var dictValue: [String : Any] {
        
        return ["eventKey" : eventKey  as Any,
                "content": content,
                "repliedTo" : repliedTo  as Any,
                "repliedBy" : repliedBy as Any,
                "creationDate": creationDate,
                "commentId" : commentId as Any,
                "profilePic" : profilePic as Any,
                "notiType" : notiType as Any]
    }
    
    var followDictValue: [String : Any] {
        
        return [
            "content": content,
            "followee" : followee as Any,
            "follower" : follower as Any,
            "creationDate": creationDate,
            "profilePic" : profilePic as Any,
            "notiType" : notiType as Any]
    }
}
extension Notifications{
    static public func  ==(rhs: Notifications, lhs: Notifications) ->Bool{
        return (rhs.commentId == lhs.commentId || rhs.followee == lhs.followee)
    }
}
extension Notifications: ListDiffable{
    public func diffIdentifier() -> NSObjectProtocol {
        if let currentCommentID = commentId {
            return currentCommentID as NSObjectProtocol
        }else {
            guard let currentFollowee = followee else {
                return followee! as NSObjectProtocol
            }
            return currentFollowee as NSObjectProtocol
        }
    }
    public func isEqual(toDiffableObject object: ListDiffable?) ->Bool{
        guard let object = object as? Notifications else {
            return false
        }
        return  self.commentId==object.commentId || self.followee == object.followee
    }
}

