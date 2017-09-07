//
//  AttendService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/13/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseAuth

struct AttendService {
    static func create(for event: Event?, success: @escaping (Bool) -> Void) {
        // 1
        guard let key = event?.key else {
            return success(false)
        }
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let attendData = ["Attending/\(key)/\(uid)" : true,
                          "users/\(uid)/\("Attending")/\(key)" : true]
        
        // 2
        let ref = Database.database().reference()
        ref.updateChildValues(attendData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            // 3
            success(error == nil)
        }
    }
    
    // 3 code to like a post
    
    
    static func fethAttendCount(for event: String?) -> Int {
        print("Fetching Attend Count")
        var numberAttending: Int = 0
        let attendRef = Database.database().reference().child("Attending").child(event!)
        attendRef.observe(.value, with: { (snapshot) in
            guard let attendCountDictionary = snapshot.value as? [String: Any] else{
                return
            }
            print(snapshot.value ?? "")
            
            numberAttending = attendCountDictionary.count
            print(numberAttending)
        }) { (err) in
            print("Failed to fetch attend count")
        }
        
        return numberAttending
        
    }
    
    
    
    
    
    
    static func delete(for event: Event?, success: @escaping (Bool) -> Void) {
        guard let key = event?.key else {
            return success(false)
        }
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let attendData = ["Attending/\(key)/\(uid)" : NSNull(),
                          "users/\(uid)/\("Attending")/\(key)" : NSNull()]
        

        
          Database.database().reference().updateChildValues(attendData){ (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            return success(error == nil)
        }
    }
    
    
    
    
    
    static func setIsAttending(_ isAttending: Bool, from event: Event?, success: @escaping (Bool) -> Void) {
        if isAttending {
            create(for: event, success: success)
        } else {
            delete(for: event, success: success)
        }
    }
    
    
    static func isEventAttended(_ event: Event?, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        guard let event = event else {
            assertionFailure("Error: event must have key.")
            return completion(false)
        }
        
        let attendRef = Database.database().reference().child("Attending").child(event.key!)
        attendRef.queryEqual(toValue: nil, childKey: User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
}
