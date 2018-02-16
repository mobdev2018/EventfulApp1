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
import DynamoCollectionView
import FirebaseDatabase
import SVProgressHUD


class ImageAndTitleItem: NSObject {
    public var name:String?
    public var imageName:String?
    
    convenience init(name:String, imageName:String) {
        self.init()
        self.name = name
        self.imageName = imageName
    }
}

class HomeFeedController: UIViewController, UIGestureRecognizerDelegate {
    // let dropDownLauncher = DropDownLauncher()
    let dispatchGroup = DispatchGroup()
    var isFinishedPaging = false
    let detailView = EventDetailViewController()
    var userLocation: CLLocation?
    let refreshControl = UIRefreshControl()
    var emptyLabel: UILabel?
    var allEvents = [Event]()
    var eventKeys = [String]()
    var featuredEvents = [Event]()
    let topCell = "topCell"
    //creates an instance of the dynamoCollectionView
    fileprivate var dynamoCollectionView: DynamoCollectionView!
    fileprivate var dynamoCollectionViewTop: DynamoCollectionViewTop!
    

    
    
    var profileHandle: DatabaseHandle = 0
    var profileRef: DatabaseReference?
    
    fileprivate var selectedTopIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        SVProgressHUD.dismiss()
        self.configure()
        grabUserLoc()
       // reloadHomeFeed()
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
                    self.dynamoCollectionView.reloadData()
                    //self.dynamoCollectionViewTop.reloadData()
                }
                
            })
            
            PostService.showFeaturedEvent(for: currentLocation, completion: { [unowned self] (events) in
                
                self.featuredEvents = events
                print("Event count in Featured Events Closure is:\(self.featuredEvents.count)")
                DispatchQueue.main.async {
                    // self.dynamoCollectionView.reloadData()
                    self.dynamoCollectionViewTop.reloadData()
                }
            }
            )


            print("Latitude: \(currentLocation.coordinate.latitude)")
            print("Longitude: \(currentLocation.coordinate.longitude)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.removeFromSuperview()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("EventDetailViewController class removed from memory")
    }

    
    private func configure(){
        print("Enter configure function")
        func configureViews(){
//takes previously created dynamoCollectionView and assigns it to and creates an instance of DynamoCollectionView
            //init for bottom dynamoCollectionView
            self.dynamoCollectionView = DynamoCollectionView(frame: .zero)
            //init for top dynamoCollectionView
            self.dynamoCollectionViewTop = DynamoCollectionViewTop(frame: .zero)
            //A Boolean value that determines whether the view’s autoresizing mask is translated into Auto Layout constraints.
            self.dynamoCollectionView.translatesAutoresizingMaskIntoConstraints = false
            self.dynamoCollectionViewTop.translatesAutoresizingMaskIntoConstraints = false

            //will allow you to supply your own data to the bottom collectionView
            self.dynamoCollectionView.dataSource = self
            //will allow you to send messages about interaction with the bottom dynamoCollectionView to self
            self.dynamoCollectionView.delegate = self
            
            //will allow you to supply your own data to the top collectionView
            self.dynamoCollectionViewTop.dataSourceTop = self
            //will allow you to send messages about interaction with the top dynamoCollectionView to self
            self.dynamoCollectionViewTop.delegateTop = self
            
            self.dynamoCollectionView.backgroundColor = .white
            self.dynamoCollectionViewTop.backgroundColor = .white

            self.view.backgroundColor = .white
            self.view.addSubview(self.dynamoCollectionView)
            self.view.addSubview(self.dynamoCollectionViewTop)
            view.addConstraintsWithFormatt("V:|-5-[v0(\(view.frame.height/2))]-2-[v1]|", views: self.dynamoCollectionViewTop,self.dynamoCollectionView)
            view.addConstraintsWithFormatt("H:|[v0]|", views: self.dynamoCollectionViewTop)
            view.addConstraintsWithFormatt("H:|[v0]|", views: self.dynamoCollectionView)
        }
        //goes here first
        configureViews()
    }

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //will make surepictures keep same orientation even if you flip screen
    // will most likely lock into portrait mode but still good to have
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.dynamoCollectionView.invalidateLayout()
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

extension HomeFeedController: DynamoCollectionViewDelegate, DynamoCollectionViewDataSource {
    
    // MARK: DynamoCollectionView Datasource
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, willDisplay cell: UICollectionViewCell, indexPath: IndexPath) {
       // print("Attempting to get events")

    }
    
    func topViewRatio(_ dynamoCollectionView: DynamoCollectionView) -> CGFloat {
        return 0.6
    }
    
    
    func numberOfItems(_ dynamoCollectionView: DynamoCollectionView) -> Int {
        //this seems to be passing data to numberofitems in DynamicCollectionView file to configure view via that file
        //seems to be doing things one view or cell at a time
       // print(allEvents.count)
        return allEvents.count
    }
    //controls info related to each cell 
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell {
       // print("entered cell for item at: \(indexPath.item) ")
        let cell = dynamoCollectionView.dequeueReusableCell(for: indexPath)
        let model = allEvents[indexPath.item]
        let imageURL = URL(string: model.currentEventImage)
        let dateComponents = self.getDayAndMonthFromEvent(model)
        cell.day = dateComponents.0
        cell.month = dateComponents.1
        cell.title = model.currentEventName.capitalized
        cell.backgroundImageView.af_setImage(withURL: imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: false) { (imageHolder) in
            cell.refreshView()
        }
        return cell
    }
    
    // MARK: DynamoCollectionView Delegate
    
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.allEvents.count <= indexPath.item {
            return
        }
        let model = self.allEvents[indexPath.item]
        detailView.eventKey = model.key!
        detailView.eventPromo = model.currentEventPromo!
        detailView.currentEvent = model
        present(detailView, animated: true, completion: nil)
    }
    
}


extension HomeFeedController: DynamoCollectionViewTopDelegate, DynamoCollectionViewTopDataSource {
    func dynamoCollectionViewTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop, didSelectItemAt indexPath: IndexPath) {
        if self.featuredEvents.count <= indexPath.item {
            return
        }
        let model = self.featuredEvents[indexPath.item]
        detailView.eventKey = model.key!
        detailView.eventPromo = model.currentEventPromo!
        detailView.currentEvent = model
        present(detailView, animated: true, completion: nil)
    }
    
    func dynamoCollectionViewTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop, willDisplay cell: UICollectionViewCell, indexPath: IndexPath) {
       //print("Attempting to get events")
    }
    
    func topViewRatioTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop) -> CGFloat {
        return 0
    }
    
    func numberOfItemsTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop) -> Int {
        return featuredEvents.count
    }
    
    func dynamoCollectionViewTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell {
      //  print("entered cell for item at: \(indexPath.item) ")
        let cell = dynamoCollectionViewTop.dequeueReusableCell(for: indexPath)
        let model = featuredEvents[indexPath.item]
        let imageURL = URL(string: model.currentEventImage)
        let dateComponents = self.getDayAndMonthFromEvent(model)
        cell.day = dateComponents.0
        cell.month = dateComponents.1
        cell.title = model.currentEventName.capitalized
        cell.backgroundImageView.af_setImage(withURL: imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: false) { (imageHolder) in
            cell.refreshView()
        }
        return cell
    }
    
    

    
}

