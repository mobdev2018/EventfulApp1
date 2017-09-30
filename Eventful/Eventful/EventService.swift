//
//  EventService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/16/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth


struct EventService {
    
    static func show(forEventKey eventKey: String, eventCategory: String? = nil, completion: @escaping (Event?) -> Void) {
        // print(eventKey)
        let ref = Database.database().reference().child("events").child(eventKey)
        // print(eventKey)
        //pull everything
        ref.observeSingleEvent(of: .value, andPreviousSiblingKeyWith: { (snapshot,eventKey) in
            print(snapshot.value ?? "")
            guard let event = Event(snapshot: snapshot) else {
                return completion(nil)
            }
            if eventCategory == nil || eventCategory == "" || eventCategory == "Home" {
                return completion(event)
            }
            
            if event.category == eventCategory{
                completion(event)
            } else {
                completion(Event(currentEventKey: "", dictionary: [:]))
            }
            
        })
        
        
        
        
    }
    
    static func showAll(_ snapshots: [DataSnapshot], eventCategory: String? = nil, index: Int, events: [Event], completion: @escaping ([Event]?) -> Void) {
        if index == snapshots.count {
            completion(events)
            return
        }
        show(forEventKey: snapshots[index].value as! String, eventCategory: eventCategory) { (event) in
            var newEvents = events
            if let event = event {
                newEvents.append(event)
            }
            showAll(snapshots, eventCategory: eventCategory, index: index + 1, events: newEvents, completion: completion)
        }
    }
    
}
