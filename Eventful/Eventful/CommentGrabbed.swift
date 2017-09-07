//
//  CommentGrabbed.swift
//  Eventful
//
//  Created by Shawn Miller on 8/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation

struct CommentGrabbed {
    let content: String
    let uid: String
    let user: User
    let creationDate: Date
    var commentID: String? = ""
    

    
    init(user: User, dictionary: [String:Any]) {
        self.content = dictionary["content"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.user = user
        let secondsFrom1970 = dictionary["timestamp"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
