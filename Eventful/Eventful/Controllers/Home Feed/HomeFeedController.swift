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
    
    let dispatchGroup = DispatchGroup()
    var savedLocation: CLLocation?
    var isFinishedPaging = false
    var userLocation: CLLocation?
    var allEvents = [Event]()
    var eventKeys = [String]()
    var featuredEvents = [Event]()
    var allEvents2 = [String:[Event]]()
    var seizeTheNight = [Event]()
    var seizeTheDay = [Event]()
    private let cellID = "cellID"
    private let catergoryCellID = "catergoryCellID"
    var images: [String] = ["gear1","gear4","snakeman","gear4","gear1"]
    var images1: [String] = ["sage","sagemode","kyubi","Naruto_Part_III","team7"]
    var featuredEventsHeaderString = "Featured Events"
    var categories : [String] = ["Seize The Night","Seize The Day","21 & Up", "Friends Events"]
    lazy var sideMenuLauncher: SideMenuLauncher = {
       let launcher = SideMenuLauncher()
        launcher.homeFeedController = self
        return launcher
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        SVProgressHUD.dismiss()
        grabUserLoc()
        setupBarButtonItems()
        collectionView?.register(HomeFeedCell.self, forCellWithReuseIdentifier: cellID)
                collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: catergoryCellID)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("EventDetailViewController class removed from memory")
    }
    
    @objc func setupBarButtonItems(){
    let sideMenuButton = UIBarButtonItem(image: UIImage(named: "icons8-Menu-48"), style: .plain, target: self, action: #selector(presentSideMenu))
    navigationItem.leftBarButtonItem = sideMenuButton
    }
    
    @objc func presentSideMenu(){
        sideMenuLauncher.presentSideMenu()
    }
    
    @objc func showControllerForCategory(sideMenu: SideMenu){
        let categoryVC = CategoryViewController(collectionViewLayout: UICollectionViewFlowLayout())
        categoryVC.titleView.text = sideMenu.name.rawValue
        categoryVC.events = self.allEvents2[sideMenu.name.rawValue]!
        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    @objc func grabUserLoc(){
        LocationService.getUserLocation { (location) in
            guard let currentLocation = location else {
                return
            }
            self.savedLocation = currentLocation
            
            PostService.showEvent(for: currentLocation, completion: { [unowned self](events) in
                
                    if events.category == "Seize The Night" {
                        self.seizeTheNight.append(events)
                    }
                    if events.category == "Seize The Day"{
                        self.seizeTheDay.append(events)
                    }
                
                self.allEvents2["Seize The Night"] = self.seizeTheNight
                self.allEvents2["Seize The Day"] = self.seizeTheDay
                print("Event count in PostService Closure:\(self.allEvents.count)")
                DispatchQueue.main.async {
                   // self.dynamoCollectionView.reloadData()
                    //self.dynamoCollectionViewTop.reloadData()
                    self.collectionView?.reloadData()

                }
                
            })
            
            PostService.showFeaturedEvent(for: currentLocation, completion: { [weak self] (events) in
                
                self?.featuredEvents = events
                print("Event count in Featured Events Closure is:\(self?.featuredEvents.count)")
                DispatchQueue.main.async {
                }
            }
            )
            print("Latitude: \(currentLocation.coordinate.latitude)")
            print("Longitude: \(currentLocation.coordinate.longitude)")
        }
        
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    private func initNavigationItemTitleView() {
        LocationService.getUserLocation { (currentLocation) in
            guard let savedLocation = currentLocation else {
                return
            }
            CLGeocoder().reverseGeocodeLocation(savedLocation, completionHandler: {(placemarks, error) -> Void in
                print(savedLocation)
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    print(pm.locality as Any)
                    print(pm.administrativeArea as Any)
                    let titleView = UILabel()
                    titleView.text = "\(pm.locality ?? ""), \(pm.administrativeArea ?? "") ▼"
                    titleView.font = UIFont(name: "Avenir", size: 18)
                    let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
                    titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
                    self.navigationItem.titleView = titleView
                    let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.titleWasTapped))
                    titleView.isUserInteractionEnabled = true
                    titleView.addGestureRecognizer(recognizer)
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    @objc private func titleWasTapped() {
        print("Hello, titleWasTapped!")
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomeFeedCell
            cell.homeFeedController = self
            cell.sectionNameLabel.text = "Featured Events"
            cell.featuredEvents = featuredEvents
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: catergoryCellID, for: indexPath) as! CategoryCell
        cell.sectionNameLabel.text = categories[indexPath.item]
        cell.homeFeedController = self
        print(categories[indexPath.item])
        print(indexPath.item)
        if allEvents2[categories[indexPath.item]]?.count != nil {
            print(allEvents2[categories[indexPath.item]])
            cell.categoryEvents = allEvents2[categories[indexPath.item]]
        } else{
            cell.categoryEvents = allEvents
        }
        return cell
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return categories.count
        }
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
             return CGSize(width: view.frame.width, height: 450)
        }
        return CGSize(width: view.frame.width, height: 300)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
        }
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}
