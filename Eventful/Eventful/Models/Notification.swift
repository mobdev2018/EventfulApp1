//
//  Notification.swift
//  Eventful
//
//  Created by Shawn Miller on 2/24/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Notifications{
    
    var content : String
    var creationDate : Double = 0
    var timeStamp : Date?
    var eventKey : String
    var key : String?
    var repliedTo : String
    var repliedBy : String
    var commentId : String
    var profilePic : String
    var notiType: String
    
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
    
    var dictValue: [String : Any] {
        
        return ["eventKey" : eventKey,
                "content": content,
                "repliedTo" : repliedTo,
                "repliedBy" : repliedBy,
                "creationDate": creationDate,
                "commentId" : commentId,
                "profilePic" : profilePic,
                "notiType" : notiType]
    }
}
