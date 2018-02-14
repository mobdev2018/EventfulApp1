//
//  FriendsEventsView.swift
//  Eventful
//
//  Created by Shawn Miller on 07/01/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Firebase

class FriendsEventsView: UITableViewController{
    var cellID = "cellID"
    var friends = [Friend]()
    var attendingEvents = [Event]()
    //label that will be displayed if there are no events
    var currentUserName: String?
    var currentUserPic: String?
    var currentEventKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Friends Events"
        view.backgroundColor = .white
        // Auto resizing the height of the cell
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close_black").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(self.goBack))
        tableView.register(EventDetailsCell.self, forCellReuseIdentifier: cellID)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            self.fetchEventsFromServer { (error) in
                if error != nil {
                    print(error)
                    return
                } else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        print("This is run on the main queue, after the previous code in outer block")
                    }
                    
                }
            }
            
            
        }

    }
    
    @objc func goBack(){
        dismiss(animated: true)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
       // print(friends.count)
        return friends.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(friends[section].events.count)
        return friends[section].collapsed ? 0 : friends[section].events.count
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! EventDetailsCell? ?? EventDetailsCell(style: .default, reuseIdentifier: cellID)
       // print(indexPath.row)
        cell.details = friends[indexPath.section].events[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
       // print(section)
        header.arrowLabel.text = ">"
        header.setCollapsed(friends[section].collapsed)
        print(friends[section].collapsed)
        header.section = section
        header.delegate = self
        header.friendDetails = friends[section]
        return header
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
   func fetchEventsFromServer(_ completion: @escaping (_ error: Error?) -> Void ){
        //will grab the uid of the current user

        guard let myUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference()
        //checking database for users that the current user is following
        ref.child("following").child(myUserId).observeSingleEvent(of: .value, with: { (followingSnapshot) in
           //handling potentail nil or error cases
            guard let following = followingSnapshot.children.allObjects as? [DataSnapshot]
                else {return}

            //validating if proper data was pulled
            let group = DispatchGroup()

            for followingId in following {
                group.enter()
                UserService.show(forUID: followingId.key, completion: { (user) in
                    PostService.showFollowingEvent(for: followingId.key, completion: { (event) in
                        self.attendingEvents = event
                        var friend = Friend(friendName: (user?.username)!, events: self.attendingEvents, imageUrl: (user?.profilePic)!)
                        self.friends.append(friend)
                        // leave here
                        group.leave()
                    })
                })
            }
            group.notify(queue: DispatchQueue.main) {
                if self.friends.count == following.count {
                    completion(nil)
                }
            }

        }) { (err) in
            completion(err)
            print("Couldn't grab people that you are currently following: \(err)")
        }

    }
}
extension FriendsEventsView: CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !friends[section].collapsed
        
        // Toggle collapse
        friends[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Reload the whole section
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
}
