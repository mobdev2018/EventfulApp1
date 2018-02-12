//
//  EventCollectionCell.swift
//  Eventful
//
//  Created by Shawn Miller on 2/10/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

protocol ExpandedCellDelegate:NSObjectProtocol{
    func viewEventsButtonTapped(indexPath:IndexPath)
}
class EventCollectionCell:UICollectionViewCell {
    var headerID = "headerID"
    weak var delegateExpand:ExpandedCellDelegate?
    public var indexPath:IndexPath!
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
    //profile image view for the user
    var profileImageView:CustomImageView={
        let iv = CustomImageView()
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.layer.borderWidth = 0.3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    //will show the name of the user as well as the total number of events he is attending
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
    
    //collectionview that contains all of the events a specific user will be attensing
    lazy var eventCollectionView:UICollectionView={
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        let spacingbw:CGFloat = 5
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        //will register the eventdetailcell
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.register(EventDetailsCell.self, forCellWithReuseIdentifier: "eventDetails")
        cv.register(FriendsEventsViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .blue
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
}

//extension that handles creation of the events detail cells as well as the eventcollectionview
//notice the delegate methods

//- Mark EventCollectionView DataSource
extension EventCollectionCell:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventArray.count
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! FriendsEventsViewHeader
        
           // header.viewEventsButton.addTarget(self, action: #selector(viewEventsButtonTapped), for: .touchUpInside)
        return header
    }
    
//    @objc func viewEventsButtonTapped(indexPath:IndexPath){
//        print("View events button touched")
//        if let delegate = self.delegateExpand{
//            delegate.viewEventsButtonTapped(indexPath: indexPath)
//        }
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"eventDetails" , for: indexPath) as! EventDetailsCell
        cell.details = eventArray[indexPath.item]
        cell.backgroundColor = .yellow
        cell.seperator1.isHidden = indexPath.item == eventArray.count-1
        return cell
    }
}

//- Mark EventCollectionView Delegate
extension EventCollectionCell:UICollectionViewDelegateFlowLayout{
    //size for each indvidual cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
}
