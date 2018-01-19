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
    let topCell = "topCell"
    //creates an instance of the dynamoCollectionView
    fileprivate var dynamoCollectionView: DynamoCollectionView!
    
    
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
            PostService.showEvent(for: currentLocation, completion: { (events) in
                self.allEvents = events
                print("Event count in PostService Closure:\(self.allEvents.count)")
                DispatchQueue.main.async {
                    self.dynamoCollectionView.reloadData()
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

    }
    
    private func configure(){
        print("Enter configure function")
        func configureViews(){
//takes previously created dynamoCollectionView and assigns it to and creates an instance of DynamoCollectionView
            self.dynamoCollectionView = DynamoCollectionView(frame: .zero)
            self.dynamoCollectionView.translatesAutoresizingMaskIntoConstraints = false
            //will allow you to supply your own data to the collectionView
            self.dynamoCollectionView.dataSource = self
            //will allow you to send messages about interaction with dynamoCollectionView to self
            self.dynamoCollectionView.delegate = self
            self.dynamoCollectionView.backgroundColor = .white
            self.view.backgroundColor = .white
            self.view.addSubview(self.dynamoCollectionView)
            NSLayoutConstraint.activateViewConstraints(self.dynamoCollectionView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topLayoutGuide, secondView: self.dynamoCollectionView, andSeparation: 0.0)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.dynamoCollectionView, secondView: self.bottomLayoutGuide, andSeparation: 0.0)
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
    
    
    fileprivate func reloadCollection() {
        self.dynamoCollectionView.reloadData()
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
        print("Attempting to get events")

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
        print("entered cell for item at: \(indexPath.item) ")
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
