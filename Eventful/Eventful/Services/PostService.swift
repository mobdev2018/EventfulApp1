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
    static func showEvent(pageSize: UInt, lastPostKey: String? = nil,eventCategory: String? = nil,completion: @escaping ([Event]) -> Void) {
        //getting firebase root directory
       // print(lastPostKey)
        print("came here")
        var currentEvents = [Event]()
        let eventsByLocationRef = Database.database().reference().child("eventsbylocation").child(User.current.location!)
        //let ref = Database.database().reference().child("events")
        var query = eventsByLocationRef.queryOrderedByKey().queryLimited(toFirst: pageSize)
        if let lastPostKey = lastPostKey {
          //  print(lastPostKey)
            query = query.queryEnding(atValue: lastPostKey)
        }
        query.observeSingleEvent(of: .value, with: { (snapshot) in
         //   print(snapshot)
           // print(snapshot.value)
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else{
                return
            }
            allObjects.forEach({ (snapshot) in
            // print(snapshot.value ?? "")
                EventService.show(forEventKey: snapshot.value as! String, completion: { (event) in
                    currentEvents.append(event!)
                   // print("\n\n\n\n\n\n")
                   // print("Finished an event")
                   // print(currentEvents.count)
                    completion(currentEvents)
                })

            })


        })

    }
    
    

}
