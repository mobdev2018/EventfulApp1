//
//  NotificationService.swift
//  Eventful
//
//  Created by Shawn Miller on 2/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import Firebase

class NotificationService {
    static func fetchUserNotif(for user: User = User.current,currentNotifCount: Int,lastKey: String, isFinishedPaging: Bool,withCompletion completion: @escaping (DatabaseReference, [Notifications],Bool) -> Void) -> DatabaseHandle {
        //array of user notifications
        var currentNotifsArray = [Notifications]()
        var currentNotif:Notifications!
       var isFinishedPagingTemp = isFinishedPaging
        //2
        let notifRef = Database.database().reference().child("Notifications").child(user.uid)
        var query = notifRef.queryOrderedByKey()
        if currentNotifCount > 0 {
            print(lastKey)
            query = query.queryStarting(atValue: lastKey)
            
        }

        return query.queryLimited(toFirst: 7).observe(.value, with: { (notifSnapshot) in
          //  print(notifSnapshot.value as Any)
            guard var allUserNotifs = notifSnapshot.children.allObjects as? [DataSnapshot] else {
                 return completion(notifRef, [],true)
            }
            
            if currentNotifCount > 0 {
                allUserNotifs.removeFirst()
                
            }
            
            if allUserNotifs.count < 1 {
                isFinishedPagingTemp = true
                return completion(notifRef,[],true)
            }
            
            for userNotifs in allUserNotifs{
                if userNotifs.childrenCount == 8 {
                  //  print("comment notification")
                    currentNotif = Notifications(snapshot:userNotifs)
                    currentNotifsArray.append(currentNotif)
                }
                if userNotifs.childrenCount == 6 {
                //    print("follow notification")
                    print(userNotifs.children.allObjects)
                    currentNotif = Notifications(followSnapshot: userNotifs)
                    currentNotifsArray.append(currentNotif)
                }
               // print(userNotifs.childrenCount)
            }
            if currentNotifsArray.count == allUserNotifs.count && !isFinishedPagingTemp{
                completion(notifRef,currentNotifsArray,false)
            }else{
                return completion(notifRef,[],true)
            }
            
        }) { (err) in
            print("Couldn't find notification info on user", err)
        }
    }
    
    static func observeNotifs(for user: User = User.current, completion: @escaping (DatabaseReference, Notifications?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("Notifications").child(user.uid)
        
        return messagesRef.queryOrdered(byChild: "creationDate").queryStarting(atValue: Date().timeIntervalSince1970).observe(.childAdded, with: { snapshot in
            if snapshot.childrenCount == 8{
                guard let notif = Notifications(snapshot: snapshot) else {
                    return completion(messagesRef, nil)
                }
                completion(messagesRef, notif)
            }
            if snapshot.childrenCount == 6{
                guard let notif = Notifications(followSnapshot: snapshot) else {
                    return completion(messagesRef, nil)
                }
                completion(messagesRef, notif)
            }
            
        })
        
    }
}
