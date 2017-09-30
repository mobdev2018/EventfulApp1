//
//  PostService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  UIKit
import Firebase


struct PostService {
    static func create(for event: String?,for vidURL: String) {
        // 1
        guard let key = event else {
            return
        }
        let storyUrl = vidURL
        // 2
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let story = Story(url: storyUrl)
        let dict = story.dictValue
        let postRef = Database.database().reference().child("Stories").child(key).childByAutoId()
        let userRef = Database.database().reference().child("users").child(uid).child("Stories").child(key).childByAutoId()
        postRef.updateChildValues(dict)
        userRef.updateChildValues(dict)
    }
    static func showEvent(pageNo: UInt, pageSize: UInt, lastPostKey: String? = nil, category: String? = nil,completion: @escaping ([Event]) -> Void) {
        //getting firebase root directory
        // print(lastPostKey)
        //  print("came here")
        let eventsByLocationRef = Database.database().reference().child("eventsbylocation").child(User.current.location!)
        //let ref = Database.database().reference().child("events")
        var query = eventsByLocationRef.queryOrderedByKey()
        if lastPostKey != nil {
            query = query.queryLimited(toFirst: pageNo * pageSize).queryStarting(atValue: lastPostKey)
        } else {
            query = query.queryLimited(toFirst: pageSize)
        }
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            //   print(snapshot)
            // print(snapshot.value)
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else{
                return
            }
            EventService.showAll(allObjects, eventCategory: category, index: 0, events: [], completion: { (events) in
                var newEvents = events
                for (index, object) in allObjects.enumerated() {
                    if newEvents?[index].key != "" {
                        newEvents?[index].key = object.key
                    }
                }
                var filterEvent: [Event] = []
                for event in newEvents! {
                    if event.key != "" {
                        filterEvent.append(event)
                    }
                }
                completion(filterEvent)
            })
        })
        
    }
    
    
    
}
