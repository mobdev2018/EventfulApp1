//
//  FriendsEventsView.swift
//  Eventful
//
//  Created by Shawn Miller on 07/01/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Firebase

class FriendsEventsView: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var friends = [Friend]()
    var followingUsers = [String]()
    var isExpanded = [Bool]()

    //so this is the main collectonview that encompasses the entire view
    //this entire view has eventcollectionCell's in it which in itself contain a collectionview which also contains cells
    //so I ultimately want to shrink the eventCollectionView
    lazy var mainCollectionView:UICollectionView={
        // the flow layout which is needed when you create any collection view
        let flow = UICollectionViewFlowLayout()
        //setting the scroll direction
        flow.scrollDirection = .vertical
        //setting space between elements
        let spacingbw:CGFloat = 5
        flow.minimumLineSpacing = spacingbw
        flow.minimumInteritemSpacing = 0
        //actually creating collectionview
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        //register a cell for that collectionview
        cv.register(EventCollectionCell.self, forCellWithReuseIdentifier: "events")
        cv.translatesAutoresizingMaskIntoConstraints = false
        //changing background color
        cv.backgroundColor = .red
        //sets the delegate of the collectionView to self. By doing this all messages in regards to the  collectionView will be sent to the collectionView or you.
        //"Delegates send messages"
        cv.delegate = self
        //sets the datsource of the collectionView to you so you can control where the data gets pulled from
        cv.dataSource = self
        //sets positon of collectionview in regards to the regular view
        cv.contentInset = UIEdgeInsetsMake(spacingbw, 0, spacingbw, 0)
        return cv
        
    }()
    
    
    //label that will be displayed if there are no events
    let labelNotEvents:UILabel={
        let label = UILabel()
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.text = "No events found"
        label.isHidden = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //will set up all the views in the screen
        self.setUpViews()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close_black").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(self.goBack))
    }
    
    func setUpViews(){
        //well set the navbar title to Friends Events
        self.title = "Friends Events"
        view.backgroundColor = .white
        
        //adds the main collection view to the view and adds proper constraints for positioning
        view.addSubview(mainCollectionView)
        mainCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        mainCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mainCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        //adds the label to alert someone that there are no events to the collectionview and adds proper constrains for positioning
        mainCollectionView.addSubview(labelNotEvents)
        labelNotEvents.centerYAnchor.constraint(equalTo: mainCollectionView.centerYAnchor, constant: 0).isActive = true
        labelNotEvents.centerXAnchor.constraint(equalTo: mainCollectionView.centerXAnchor, constant: 0).isActive = true
        //will fetch events from server
        self.fetchEventsFromServer()
        
    }
    
    
    
    // MARK: CollectionView Datasource for maincollection view
//will let us know how many eventCollectionCells tht contain collectionViews will be displayed
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(friends.count)
        isExpanded = Array(repeating: false, count: friends.count)
        return friends.count
    }
    //will control the size of the eventCollectionCells that contain collectionViews
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let event = friends[indexPath.item]
        var height:CGFloat = 100
        if let count = event.events?.count,count != 0{
            height += (CGFloat(count*40)+10)
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
    //will do the job of effieicently creating cells for the eventcollectioncell that contain eventCollectionViews using the dequeReusableCells function
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "events", for: indexPath) as! EventCollectionCell
        cell.backgroundColor = UIColor.orange
        cell.indexPath = indexPath
       // cell.delegateExpand = self
        cell.enentDetails = friends[indexPath.item]
        return cell
    }
    
    ///will fetch events from the serever
    func fetchEventsFromServer(){
        guard let myUserId = Auth.auth().currentUser?.uid else {
            return
        }
        self.labelNotEvents.isHidden = false
        let ref = Database.database()
        
        let selectedCategory = ViewToShowOnSideMenu.titleDataSouce[ViewToShowOnSideMenu.selectedCell]
      
        
        ref.reference(withPath: "following").child(myUserId).observeSingleEvent(of: .value) { (followingSnapsot) in
            if let followingIdsFromFirebase = followingSnapsot.value as? [String:Any]{
                
                for followingId in Array(followingIdsFromFirebase.keys){
                    if let following = followingIdsFromFirebase[followingId] as? Bool,following{
                        self.followingUsers.append(followingId)
                    }
                }
                
                
                //for some odd reason queries and pulls back all users
                //this has to change
                ref.reference(withPath: "users").observeSingleEvent(of: .value, with: { (usersSnapShot) in
                    if let userDetails = usersSnapShot.value as? [String:Any]{
                        ref.reference(withPath: "events").observeSingleEvent(of: .value, with: { snapshot in
                            if let evenDetailObject = snapshot.value as? [String:Any]{
                                let userKeys = Array(userDetails.keys)
                                for useKey in userKeys{
                                    if !self.followingUsers.contains(useKey){
                                        continue
                                    }
                                    //will create the user object to help create the cell it seems
                                    if let userObject = userDetails[useKey] as? [String:Any]{
                                       //creates friend object which contains the username, profilepic, and array of events that he is going to in addition to his ID
                                        let event = Friend()
                                        //gets the user name and assigns while also make sure to protect against null value
                                        if let name = userObject["username"] as? String{
                                            event.friendName = name
                                        }
                                        //gets the image url and assigns while also make sure to protect against null value
                                        if let url = userObject["profilePic"] as? String{
                                            event.imageUrl = url
                                        }
                                        //will parse the attending node under the specific user name
                                        if let attendingEvents = userObject["Attending"] as? [String:Any]{
                                            //will create a variable that holds an array of event details objects
                                            //each event detail object contains all information in regards to an  event
                                            var detailsArray = [EventDetails]()
                                            //will create an array of all the event keys pulled from the attending node
                                            let eventKeys = Array(attendingEvents.keys)
                                            //will cycle through the eventKeys and perform some operation on each one of them
                                            for eventId in eventKeys{
                                                //seems to assign a true or false value depending on if a user is going to an event or not
                                                if let going = attendingEvents[eventId] as? Bool,going{
                                                    //will grab current event info assuming it is in the user node and database
                                                    if let eventDetails = evenDetailObject[eventId] as? [String:Any]{
                                                        //will create a specific instance of a detail object
                                                        let detail1 = EventDetails()
                                                        detail1.eventId = eventId
                                                        //will get the name
                                                        if let value = eventDetails["event:name"] as? String{
                                                            detail1.name = value
                                                        }
                                                        //will get the category
                                                        if let value = eventDetails["event:category"] as? String{
                                                            let selected_cat = selectedCategory.replacingOccurrences(of: " ", with: "").lowercased()
                                                            if selected_cat != "home",value.replacingOccurrences(of: " ", with: "").lowercased() != selected_cat{
                                                                //it will not include this category as its not selected
                                                                continue
                                                            }
                                                           
                                                            detail1.category = value
                                                        }
                                                        if let value = eventDetails["event:description"] as? String{
                                                            detail1.desc = value
                                                        }
                                                        if let value = eventDetails["attend:count"] as? Int{
                                                            detail1.totalCount = value
                                                        }
                                                        if let value = eventDetails["event:imageURL"] as? String{
                                                            detail1.imageURL = value
                                                        }
                                                        if let value = eventDetails["event:promo"] as? String{
                                                            detail1.promo = value
                                                        }
                                                        if let value = eventDetails["event:city"] as? String{
                                                            detail1.city = value
                                                        }
                                                        if let value = eventDetails["event:state"] as? String{
                                                            detail1.state = value
                                                        }
                                                        if let value = eventDetails["event:street:address"] as? String{
                                                            detail1.streetAddress = value
                                                        }
                                                        if let value = eventDetails["event:zip"]{
                                                            detail1.zip = String(describing: value)
                                                        }
                                                        
                                                        if let eventDate = eventDetails["event:date"] as? [String:Any],let startDate = eventDate["start:date"] as? String{
                                                            
                                                            if let endDate = eventDate["end:date"] as? String{
                                                                detail1.endDate = endDate
                                                            }
                                                            
                                                            
                                                            if let value = eventDate["end:time"] as? String{
                                                                detail1.endTime = value
                                                            }
                                                            if let value = eventDate["start:time"] as? String{
                                                                detail1.startTime = value
                                                            }
                                                            detail1.startDate = startDate
                                                            
                                                            let df = DateFormatter()
                                                            df.dateFormat = "MM/dd/yyyy"
                                                            df.timeZone = NSTimeZone(name: "UTC") as TimeZone!
                                                            
                                                            if let eventStartDate = df.date(from: startDate){
                                                                //will onlu populate cells with events that are going to occur within the week of the current date
                                                                //first checks if the sidemenu date is either earlier or the same as eventstart date
                                                                //second checks if the sidemenu endDate is either greater than or the same as the eventStartDate
                                                                detailsArray.append(detail1)
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            for detail in detailsArray{
                                                print(detail)
                                            }
                                            event.events = detailsArray
                                        }
                                        self.friends.append(event)
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async(execute: {
                                
                                self.labelNotEvents.isHidden = self.friends.count != 0
                                self.friends.sort(by: { (fr1, _) -> Bool in
                                    if let _ = fr1.events{
                                        return true
                                    }
                                    return false
                                })
                                self.mainCollectionView.reloadData()
                            })
                        })
                    }
                    
                })
            }
        }
 }
    
    @objc func goBack(){
        dismiss(animated: true)
    }
    
}



