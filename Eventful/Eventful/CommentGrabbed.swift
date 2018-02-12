//
//  CommentGrabbed.swift
//  Eventful
//
//  Created by Shawn Miller on 8/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  IGListKit

class CommentGrabbed: NSObject {
    let content: String
    let uid: String
    var user: User?
    let creationDate: Date
    var commentID: String? = ""
    let eventKey:String
    
    var replies = [ReplyToComment]()
    
    init(user: User, dictionary: [String:Any], replies : [ReplyToComment]) {
        self.content = dictionary["content"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.eventKey = dictionary["eventKey"] as? String ?? ""
        self.user = user
        let secondsFrom1970 = dictionary["timestamp"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.replies = replies
    }
    
}


extension CommentGrabbed{
    static public func  ==(rhs: CommentGrabbed, lhs: CommentGrabbed) ->Bool{
        return (rhs.commentID == lhs.commentID && rhs.replies.count == lhs.replies.count)
    }
}

extension CommentGrabbed: ListDiffable{
    public func diffIdentifier() -> NSObjectProtocol {
        return commentID! as NSObjectProtocol
    }
    public func isEqual(toDiffableObject object: ListDiffable?) ->Bool{
        guard let object = object as? CommentGrabbed else {
            return false
        }
        return  (self.commentID==object.commentID && self.replies.count == object.replies.count)
    }
}

