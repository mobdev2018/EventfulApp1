//
//  Users.swift
//  Eventful
//
//  Created by Dad's Gift on 05/02/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class Users: NSObject {
    var allUsers : NSMutableDictionary!
    
    var userNameArray = [String]()
    
    static let sharedInstance = Users()
    
    public func getUsersNames() -> [String]{
        for obj in allUsers.allValues{
            let user = obj as! User
            if (user.uid != User.current.uid){
                self.userNameArray.append(user.username!)
            }
        }
        return self.userNameArray
    }
}
