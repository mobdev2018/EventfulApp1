//
//  User.swift
//  Eventful
//
//  Created by Shawn Miller on 7/26/17.
//  Copyright © 2017 Make School. All rights reserved.
//
import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User : NSObject {
    
    //User variables
    let uid : String
    let gender : String?
    let username : String?
    let profilePic: String?
    var location: String?
    var isFollowed = false
    let bio: String?
    var dictValue: [String : Any] {
        return ["gender" : gender as Any,
                "username" : username as Any,
                "profilePic" : profilePic as Any,
                "Bio" : bio as Any, "location": location as Any]
    }
    
    //Standard User init()
    init(uid: String, username: String, gender: String, profilePic: String, bio: String, location: String = "") {
        self.uid = uid
        self.username = username
        self.gender = gender
        self.profilePic = profilePic
        self.bio = bio
    self.location = location
        super.init()
    }
    
    //User init using Firebase snapshots
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let gender = dict["gender"] as? String,
            let username = dict["username"] as? String,
            let profilePic = dict["profilePic"] as? String,
            let bio = dict["bio"] as? String,
        let location = dict["location"] as? String
            else { return nil }
        self.uid = snapshot.key
        self.gender = gender
        self.location = location
        self.username = username
        self.profilePic = profilePic
        self.bio = bio
    }
    
    //UserDefaults
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let gender = aDecoder.decodeObject(forKey: "gender") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String,
            let profilePic = aDecoder.decodeObject(forKey: "profilePic") as? String,
            let bio = aDecoder.decodeObject(forKey: "bio") as? String,
            let location = aDecoder.decodeObject(forKey: "location") as? String
            else { return nil }
        
        self.uid = uid
        self.gender = gender
        self.username = username
        self.profilePic = profilePic
        self.bio = bio
        self.location = location
        super.init()
    }
    
    
    init?(key: String, postDictionary: [String : Any]) {
        //var dict : [String : Any]
        //print(postDictionary as? [String:])
        let dict = postDictionary
        print(dict)
        let profilePic = dict["profilePic"] as? String ?? ""
        let bio = dict["bio"] as? String ?? ""
        let username = dict["username"] as? String ?? ""
        let gender = dict["gender"] as? String ?? ""
        let location = dict["location"] as? String ?? ""
        
        self.uid = key
        self.location = location
        self.profilePic = profilePic
        self.username = username
        self.gender = gender
        self.bio = bio
    }
    
    
    //User singleton for currently logged user
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        return currentUser
    }
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = true) {
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)

            UserDefaults.standard.set(data, forKey: "currentUser")
            UserDefaults.standard.synchronize()
        }
        
        _current = user
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(profilePic, forKey: "profilePic")
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(location, forKey: "location")

    }
}
