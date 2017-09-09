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
     
            if eventCategory == "Home" || eventCategory == nil{
                //pull everything
                ref.observeSingleEvent(of: .value, andPreviousSiblingKeyWith: { (snapshot,eventKey) in
                    //print(snapshot.value ?? "")
                    guard let event = Event(snapshot: snapshot) else {
                        return completion(nil)
                    }
                    completion(event)
                })

            }else{
                //pull based off of category
                
                print("Begin Query By Event Category")
                var query = ref.queryOrdered(byChild: "event:category").queryEqual(toValue: eventCategory)
            }
        
        
    }
}
