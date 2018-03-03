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
    static func fetchUserNotif(completion: @escaping ([Notifications]) -> Void){
        //array of user notifications
        var currentNotifsArray = [Notifications]()
        var currentNotif:Notifications!

        //1
        guard let currentUserUID = Auth.auth().currentUser?.uid else{
            return
        }
        //2
        let notifRef = Database.database().reference().child("Notifications").child(currentUserUID)
        notifRef.observe(.value, with: { (notifSnapshot) in
            print(notifSnapshot.value as Any)
            guard let allUserNotifs = notifSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            for userNotifs in allUserNotifs{
                if userNotifs.childrenCount == 8 {
                    print("comment notification")
                    currentNotif = Notifications(snapshot:userNotifs)
                    currentNotifsArray.append(currentNotif)
                }
                if userNotifs.childrenCount == 6 {
                    print("follow notification")
                    print(userNotifs.children.allObjects)
                    currentNotif = Notifications(followSnapshot: userNotifs)
                    currentNotifsArray.append(currentNotif)
                }
                print(userNotifs.childrenCount)
            }
            if currentNotifsArray.count == allUserNotifs.count{
                completion(currentNotifsArray)
            }
            
            
        }) { (err) in
            print("Couldn't find notification info on user", err)
        }
        
    }
}
