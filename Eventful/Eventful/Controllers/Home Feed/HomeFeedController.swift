//
//  HomeFeedController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/28/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftLocation
import CoreLocation
import FirebaseDatabase
import SVProgressHUD
import SkeletonView


class ImageAndTitleItem: NSObject {
    public var name:String?
    public var imageName:String?
    
    convenience init(name:String, imageName:String) {
        self.init()
        self.name = name
        self.imageName = imageName
    }
}

class HomeFeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // let dropDownLauncher = DropDownLauncher()
    let dispatchGroup = DispatchGroup()
    var isFinishedPaging = false
    var userLocation: CLLocation?
    var allEvents = [Event]()
    var eventKeys = [String]()
    var featuredEvents = [Event]()
    private let cellID = "cellID"
    private let catergoryCellID = "catergoryCellID"
    var images: [String] = ["gear1","gear4","snakeman","gear4","gear1"]
        var images1: [String] = ["sage","sagemode","kyubi","Naruto_Part_III","team7"]
    var featuredEventsHeaderString = "Featured Events"
    var categories : [String] = ["Seize The Night","Seize The Day","21 & Up", "Friends Events"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "Featured Events"
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        SVProgressHUD.dismiss()
        grabUserLoc()
        collectionView?.register(HomeFeedCell.self, forCellWithReuseIdentifier: cellID)
                collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: catergoryCellID)
       // reloadHomeFeed()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.view.removeFromSuperview()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("EventDetailViewController class removed from memory")
    }
    
    

    
    @objc func grabUserLoc(){
        
        LocationService.getUserLocation { (location) in
            guard let currentLocation = location else {
                return
            }
            PostService.showEvent(for: currentLocation, completion: { [unowned self](events) in
                self.allEvents = events
                print("Event count in PostService Closure:\(self.allEvents.count)")
                DispatchQueue.main.async {
                   // self.dynamoCollectionView.reloadData()
                    //self.dynamoCollectionViewTop.reloadData()
                    self.collectionView?.reloadData()

                }
                
            })
            
            PostService.showFeaturedEvent(for: currentLocation, completion: { [unowned self] (events) in
                
                self.featuredEvents = events
                print("Event count in Featured Events Closure is:\(self.featuredEvents.count)")
                DispatchQueue.main.async {
                    // self.dynamoCollectionView.reloadData()
                   // self.dynamoCollectionViewTop.reloadData()
                    self.collectionView?.reloadData()
                }
            }
            )
            print("Latitude: \(currentLocation.coordinate.latitude)")
            print("Longitude: \(currentLocation.coordinate.longitude)")
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomeFeedCell
            cell.sectionNameLabel.text = "Featured Events"
            cell.featuredEvents = featuredEvents
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: catergoryCellID, for: indexPath) as! CategoryCell
        cell.sectionNameLabel.text = categories[indexPath.item]
        print(categories[indexPath.item])
        print(indexPath.item)
        cell.categoryEvents = allEvents
        return cell
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return 4
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
             return CGSize(width: view.frame.width, height: 300)
        }
        return CGSize(width: view.frame.width, height: 300)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    


    fileprivate func getDayAndMonthFromEvent(_ event:Event) -> (String, String) {
        let apiDateFormat = "MM/dd/yyyy"
        let df = DateFormatter()
        df.dateFormat = apiDateFormat
        let eventDate = df.date(from: event.currentEventDate!)!
        df.dateFormat = "dd"
        let dayElement = df.string(from: eventDate)
        df.dateFormat = "MMM"
        let monthElement = df.string(from: eventDate)
        return (dayElement, monthElement)
    }
}






