//
//  FriendsEventsView.swift
//  Eventful
//
//  Created by MacBook Pro on 07/01/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Firebase

class FriendsEventsView: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var friends = [Friend]()
    var followingUsers = [String]()
    
    lazy var mainCollectionView:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        let spacingbw:CGFloat = 5
        flow.minimumLineSpacing = spacingbw
        flow.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.register(EventCollectionCell.self, forCellWithReuseIdentifier: "events")
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsetsMake(spacingbw, 0, spacingbw, 0)
        return cv
        
    }()
    
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
        self.setUpViews()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close_black").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(self.goBack))
    }
    
    func setUpViews(){
        self.title = "Friends Events"
        view.backgroundColor = .white
        
        
        view.addSubview(mainCollectionView)
        mainCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        mainCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mainCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        
        mainCollectionView.addSubview(labelNotEvents)
        labelNotEvents.centerYAnchor.constraint(equalTo: mainCollectionView.centerYAnchor, constant: 0).isActive = true
        labelNotEvents.centerXAnchor.constraint(equalTo: mainCollectionView.centerXAnchor, constant: 0).isActive = true
        
        self.fetchEventsFromServer()
        
    }
    
    
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 50
        let event = friends[indexPath.item]
        if let count = event.events?.count,count != 0{
            height += (CGFloat(count*40)+10)
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "events", for: indexPath) as! EventCollectionCell
        cell.enentDetails = friends[indexPath.item]
        
        return cell
    }
    
    
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
                
                ref.reference(withPath: "users").observeSingleEvent(of: .value, with: { (usersSnapShot) in
                    if let userDetails = usersSnapShot.value as? [String:Any]{
                        ref.reference(withPath: "events").observeSingleEvent(of: .value, with: { snapshot in
                            if let evenDetailObject = snapshot.value as? [String:Any]{
                                let userKeys = Array(userDetails.keys)
                                for useKey in userKeys{
                                    if !self.followingUsers.contains(useKey){
                                        continue
                                    }
                                    if let userObject = userDetails[useKey] as? [String:Any]{
                                        let event = Friend()
                                        if let name = userObject["username"] as? String{
                                            event.friendName = name
                                        }
                                        if let url = userObject["profilePic"] as? String{
                                            event.imageUrl = url
                                        }
                                        if let attendingEvents = userObject["Attending"] as? [String:Any]{
                                            
                                            var detailsArray = [EventDetails]()
                                            let eventKeys = Array(attendingEvents.keys)
                                            for eventId in eventKeys{
                                                if let going = attendingEvents[eventId] as? Bool,going{
                                                    if let eventDetails = evenDetailObject[eventId] as? [String:Any]{
                                                        let detail1 = EventDetails()
                                                        detail1.eventId = eventId
                                                        
                                                        if let value = eventDetails["event:name"] as? String{
                                                            detail1.name = value
                                                        }
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
                                                                if (SideMenu.getStartDateEndDate().startDate.compare(eventStartDate) == .orderedAscending || SideMenu.getStartDateEndDate().startDate.compare(eventStartDate) == .orderedSame),(SideMenu.getStartDateEndDate().endDate.compare(eventStartDate) == .orderedDescending || SideMenu.getStartDateEndDate().endDate.compare(eventStartDate) == .orderedSame)  {
                                                                    detailsArray.append(detail1)
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                                }
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

//class that handles creation of the events detail cells
class EventCollectionCell:UICollectionViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    var eventArray = [EventDetails](){
        didSet{
            self.eventCollectionView.reloadData()
        }
    }
    var enentDetails:Friend?{
        didSet{
            
            var name = "N/A"
            var total = 0
            seperator.isHidden = true
            if let value = enentDetails?.friendName{
                name = value
            }
            if let value = enentDetails?.events{
                total = value.count
                self.eventArray = value
                seperator.isHidden = false
            }
            if let value = enentDetails?.imageUrl{
                profileImageView.loadImage(urlString: value)
            }else{
                profileImageView.image = #imageLiteral(resourceName: "Tokyo")
            }
            
            self.eventCollectionView.reloadData()
            setLabel(name: name, totalEvents: total)
        }
    }
    
    let container:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.3
        return view
    }()
    
    var profileImageView:CustomImageView={
        let iv = CustomImageView()
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.layer.borderWidth = 0.3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let labelNameAndTotalEvents:UILabel={
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let seperator:UIView={
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var eventCollectionView:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        let spacingbw:CGFloat = 5
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.register(EventDetailsCell.self, forCellWithReuseIdentifier: "eventDetails")
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsetsMake(spacingbw, 0, spacingbw, 0)
        cv.showsVerticalScrollIndicator = false
        cv.bounces = false
        return cv
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func setUpCell(){
        addSubview(container)
        container.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        container.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        container.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        container.addSubview(profileImageView)
        container.addSubview(labelNameAndTotalEvents)
        container.addSubview(seperator)
        container.addSubview(eventCollectionView)
        
        let sizeOfImage:CGFloat = 40
        profileImageView.heightAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        profileImageView.layer.cornerRadius = sizeOfImage/2
        profileImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 5).isActive = true
    
        labelNameAndTotalEvents.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 0).isActive = true
        labelNameAndTotalEvents.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        labelNameAndTotalEvents.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -5).isActive = true
        labelNameAndTotalEvents.heightAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        
        
        seperator.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -5).isActive = true
        seperator.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 5).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        seperator.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5).isActive = true
        
        eventCollectionView.topAnchor.constraint(equalTo: seperator.bottomAnchor, constant: 0).isActive = true
        eventCollectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
        eventCollectionView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 10).isActive = true
        eventCollectionView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -5).isActive = true
    }
    
    func setLabel(name:String,totalEvents:Int){
        let mainString = NSMutableAttributedString()
        
        let attString = NSAttributedString(string:name+"\n" , attributes: [NSAttributedStringKey.foregroundColor:UIColor.black,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)])
        mainString.append(attString)
        
        let attString2 = NSAttributedString(string:totalEvents == 0 ? "No events" : "\(totalEvents) \(totalEvents == 1 ? "Event" : "Events")" , attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray,NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 12)])
        mainString.append(attString2)
      
        labelNameAndTotalEvents.attributedText = mainString
   
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventArray.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventDetails", for: indexPath) as! EventDetailsCell
        cell.details = eventArray[indexPath.item]
        cell.seperator1.isHidden = indexPath.item == eventArray.count-1
        
        return cell
    }
    
    
    
}


class EventDetailsCell:UICollectionViewCell{
    
    var details:EventDetails?{
        didSet{
            if let value = details?.name{
                labelDesciption.text = value
            }else{
                labelDesciption.text = "Uknown"
            }
            if let value = details?.startDate{
               var dateString = ""
                dateString = "From "+value
                if let startTime = details?.startTime{
                    dateString += ",\(startTime)"
                }
                if let end = details?.endDate{
                   dateString += " to \(end)"
                }
                if let endTime = details?.endTime{
                    dateString += ",\(endTime)"
                }
                labelDate.text = dateString
            }else{
                labelDate.text = "Uknown"
            }
        }
    }
    
    let labelDesciption:UILabel={
        let label = UILabel()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    let labelDate:UILabel={
        let label = UILabel()
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let seperator1:UIView={
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(seperator1)
        addConstraintsWithFormatt("H:|[v0]|", views: seperator1)
        addConstraintsWithFormatt("V:[v0(0.3)]|", views: seperator1)
        
        addSubview(labelDesciption)
        addSubview(labelDate)
        addConstraintsWithFormatt("H:|-5-[v0]-5-|", views: labelDesciption)
        addConstraintsWithFormatt("H:|-5-[v0]-5-|", views: labelDate)
        addConstraintsWithFormatt("V:|-4-[v0]-4-[v1]-4-|", views: labelDesciption,labelDate)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Friend:NSObject{
   
    var friendName:String?
    var imageUrl:String?
    var events:[EventDetails]?
    var id:Int?
    
}

class EventDetails:NSObject{
    var eventId:String?
    var totalCount:Int?
    var category:String?
    var city:String?
    var state:String?
    var streetAddress:String?
    var zip:String?
    var desc:String?
    var imageURL:String?
    var name:String?
    var promo:String?
    
    var startDate:String?
    var startTime:String?
    var endDate:String?
    var endTime:String?
    
  
}

