//
//  ReplyToComment.swift
//  Eventful
//
//  Created by Dad's Gift on 01/02/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import IGListKit

class ReplyToComment {
    var replyId: String? = ""
    var content: String
    let timeStamp: Date
    let user: User
    let profilePic: String
    let uid: String
    let eventKey: String
//    let creationDate: Date
    
   
    init(dictionary:[String:Any], user: User) {
        self.content = dictionary["content"] as! String
        self.profilePic = dictionary["profileImageURL"] as! String
        self.uid = dictionary["uid"] as! String
        self.eventKey = dictionary["eventKey"] as! String
        self.user = user
        let secondsFrom1970 = dictionary["timestamp"] as? Double ?? 0
        self.timeStamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
    
    var dictValue: [String : Any] {
        
        return ["uid" : User.current.uid,
                "profileImageURL": User.current.profilePic ?? "",
                "content" : content,
                "timestamp" : timeStamp.timeIntervalSince1970,
                "eventKey": eventKey]
    }
}

