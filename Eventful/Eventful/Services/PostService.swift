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
    
    //used in my pagination
    static func showEvent(pageSize: UInt, lastPostKey: String? = nil, category: String? = nil,completion: @escaping ([Event],String) -> Void) {
        //getting firebase root directory
        // print(lastPostKey)
        //  print("came here")
        var currentEvents = [Event]()
        let eventsByLocationRef = Database.database().reference().child("eventsbylocation").child("37%2e7,-122%2e4")
        //let ref = Database.database().reference().child("events")
        var query = eventsByLocationRef.queryOrderedByKey()
        //        if let lastPostKey = lastPostKey {
        //            //  print(lastPostKey)
        //            query = query.queryStarting(atValue: lastPostKey).queryLimited(toFirst: pageSize + 1)
        //        } else {
        //            query = query.queryLimited(toFirst: pageSize)
        //        }
        var isStart = false
        if let lastPostKey = lastPostKey {
            if category == nil || category == "" || category == "Home" {
                query = query.queryStarting(atValue: lastPostKey).queryLimited(toFirst: pageSize + 1)
                isStart = true
            }else{
                query = eventsByLocationRef.queryOrdered(byChild: "category").queryEqual(toValue: category)
            }
        }else{
            if category == nil || category == "" || category == "Home" {
                query = query.queryLimited(toFirst: pageSize)
                isStart = true
            }else{
                query = eventsByLocationRef.queryOrdered(byChild: "category").queryEqual(toValue: category).queryLimited(toFirst: pageSize)
                isStart = true
            }
        }
        var nCount = 0
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            //   print(snapshot)
            // print(snapshot.value)
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else{
                return
            }
            var filteredObjects = allObjects
            if let _ = lastPostKey {
                filteredObjects.removeFirst()
            }
            var key = ""
            
            filteredObjects.forEach({ (snapshot) in
                // print(snapshot.value ?? "")
                //                print(category ?? "")
                key = snapshot.key
                let value = snapshot.value as! [String:Any];
                if((value["name"] as! String) == lastPostKey){
                    isStart = true
                    nCount = 0
                }
                if(isStart && nCount < pageSize){
                    EventService.show(forEventKey: value["name"] as! String ,eventCategory: category, completion: { (event) in
                        currentEvents.append(event!)
                        completion(currentEvents,key)
                    })
                }
            })
            
            
        })
        
    }
    
    
    
}

