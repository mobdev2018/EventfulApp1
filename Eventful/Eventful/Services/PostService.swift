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
import GeoFire
import CoreLocation


class PostService {
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
    
    static func showEvent(for currentLocation: CLLocation,completion: @escaping (Event) -> Void) {
        //getting firebase root directory
        var currentEvents: Event
        var geoFireRef: DatabaseReference?
        var geoFire:GeoFire?
        geoFireRef = Database.database().reference().child("eventsbylocation")
        geoFire = GeoFire(firebaseRef: geoFireRef!)
        let circleQuery = geoFire?.query(at: currentLocation, withRadius: 17.0)
        circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            let dispatchGroup = DispatchGroup()

            print("Key '\(key)' entered the search area and is at location '\(location)'")
            dispatchGroup.enter()
            EventService.show(forEventKey: key, completion: { (event) in
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    completion(event!)
                })
                
            })

        })

    }
    
    static func showFeaturedEvent(for currentLocation: CLLocation,completion: @escaping ([Event]) -> Void) {
        //getting firebase root directory
        var currentEvents = [Event]()
        var geoFireRef: DatabaseReference?
        var geoFire:GeoFire?
        geoFireRef = Database.database().reference().child("featuredeventsbylocation")
        geoFire = GeoFire(firebaseRef: geoFireRef!)
        let circleQuery = geoFire?.query(at: currentLocation, withRadius: 17.0)
        circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            let dispatchGroup = DispatchGroup()
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            dispatchGroup.enter()
            EventService.show(forEventKey: key, completion: { (event) in
                dispatchGroup.leave()
                currentEvents.append(event!)
            })
            dispatchGroup.notify(queue: .main, execute: {
                completion(currentEvents)
            })
        })
        
    }
    
    static func showFollowingEvent(for followerKey: String,completion: @escaping (Event) -> Void) {
        //getting firebase root directory
        let ref = Database.database().reference()

        ref.child("users").child(followerKey).child("Attending").observeSingleEvent(of: .value, with: { (attendingSnapshot) in
            print(attendingSnapshot)
            guard var eventKeys = attendingSnapshot.children.allObjects as? [DataSnapshot] else{return}
            for event in eventKeys{
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                EventService.show(forEventKey: event.key, completion: { (event) in
                    dispatchGroup.leave()
                    completion(event!)
                })
            }
        }) { (err) in
            print("couldn't grab event info",err)

        }
    }
    
}

