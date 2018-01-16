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
    var isFinishedPaging = false
    let detailView = EventDetailViewController()
    var userLocation: CLLocation?
    let refreshControl = UIRefreshControl()
    var emptyLabel: UILabel?
    var allEvents = [Event]()
    //will containt array of event keys
    var eventKeys = [String]()
    //let eventCellIdentifier = "customCellIdentifier"
    //look here for topCell identifier
    let topCell = "topCell"
    
    //fileprivate var collectionView:UICollectionView!
    //fileprivate var topView:HomeFeedCell!
    fileprivate var topCollectionView:UICollectionView!
    fileprivate var dynamoCollectionView: DynamoCollectionView!
    
    let dropDown: [ImageAndTitleItem] = {
        return [ImageAndTitleItem(name: "Home", imageName: "home"), ImageAndTitleItem(name: "Seize The Night", imageName: "night"), ImageAndTitleItem(name: "Seize The Day", imageName: "summer"), ImageAndTitleItem(name: "Dress To Impress", imageName: "suit"), ImageAndTitleItem(name: "I Love College", imageName: "college"), ImageAndTitleItem(name: "21 & Up", imageName: "21")]
    }()
    
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
                for event in events {
                                  if !self.allEvents.contains(where: {$0.key == event.key}) {
                                       self.allEvents.append(event)
                                   }
                }
                print(self.allEvents.count)
                
            })
           // self.userLocation = currentLocation
            print("Latitude: \(currentLocation.coordinate.latitude)")
            print("Longitude: \(currentLocation.coordinate.longitude)")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if self.selectedTopIndex == nil {
            self.performActionOnTopItemSelect(at: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    private func configure(){
        print("Enter configure function")
        func configureViews(){
            let topLayout = UICollectionViewFlowLayout()
            topLayout.scrollDirection = .horizontal
            self.topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: topLayout)
            //self.topCollectionView.tag = 0
            //top collection View controls the top categories section
            //any code here that references it just sets it up or positions it
            self.topCollectionView.backgroundColor = .white
            self.topCollectionView.dataSource = self
            self.topCollectionView.delegate = self
            self.topCollectionView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.topCollectionView)
            NSLayoutConstraint.activateViewConstraints(self.topCollectionView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 50.0)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topLayoutGuide, secondView: self.topCollectionView, andSeparation: 0.0)
            //this controls the adding of all the views that correspond to the top and bottom collecionView that is contained in the dynamoCollectionView project
            self.dynamoCollectionView = DynamoCollectionView(frame: .zero)
            self.dynamoCollectionView.translatesAutoresizingMaskIntoConstraints = false
            //will allow you to supply uour own data to the collectionView
            self.dynamoCollectionView.dataSource = self
            //will allow you to send messages about interaction with dynamoCollectionView to self
            self.dynamoCollectionView.delegate = self
            self.dynamoCollectionView.backgroundColor = .white
            self.view.backgroundColor = .white
            self.view.addSubview(self.dynamoCollectionView)
            
            NSLayoutConstraint.activateViewConstraints(self.dynamoCollectionView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topCollectionView, secondView: self.dynamoCollectionView, andSeparation: 0.0)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.dynamoCollectionView, secondView: self.bottomLayoutGuide, andSeparation: 0.0)
        }
        
        func configureCollectionCell(){
            //self.collectionView.register(HomeFeedCell.self, forCellWithReuseIdentifier: eventCellIdentifier)
            //will register a category collectionview cell
            self.topCollectionView.register(DropDownCell.self, forCellWithReuseIdentifier: topCell)
        }
        //goes here first
        configureViews()
        configureCollectionCell()
    }
    
    fileprivate func performActionOnTopItemSelect(at index:Int) {
        let current = IndexPath(item: index, section: 0)
        var indexPaths:[IndexPath] = [current]
        if self.selectedTopIndex != nil {
            if self.selectedTopIndex == index {
                return
            }
            else {
                let old = IndexPath(item: self.selectedTopIndex!, section: 0)
                indexPaths.append(old)
                self.selectedTopIndex = index
            }
        }
        else {
            self.selectedTopIndex = index
        }
        self.topCollectionView.performBatchUpdates({
            self.topCollectionView.reloadItems(at: indexPaths)
        }, completion: nil)
        let dropDown = self.dropDown[index]
        self.categoryFetch(dropDown: dropDown)
    }
    
    //will query by selected category
    func categoryFetch(dropDown: ImageAndTitleItem){
        navigationItem.title = dropDown.name
    }
    

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //will make surepictures keep same orientation even if you flip screen
    // will most likely lock into portrait mode but still good to have
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //self.collectionView.collectionViewLayout.invalidateLayout()
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




// MARK: - UICollectionViewDelegateFlowLayout
extension HomeFeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performActionOnTopItemSelect(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWith = self.dropDown[indexPath.item].name!.textRect(withFont: UIFont.systemFont(ofSize: 13), andHeight: 20.0).size.width + 44.0
        return CGSize(width: cellWith, height: collectionView.bounds.size.height - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 15.0, 10.0, 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

// MARK: - UICollectionViewDataSource
extension HomeFeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dropDown.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topCell, for: indexPath) as! DropDownCell
        let dropDown = self.dropDown[indexPath.row]
        cell.dropDown = dropDown
        var selected = false
        if self.selectedTopIndex != nil && self.selectedTopIndex == indexPath.item {
            selected = true
        }
        cell.backgroundColor = selected ? UIColor.darkGray : UIColor.white
        cell.nameLabel.textColor = selected ? UIColor.white : UIColor.black
        cell.iconImageVIew.tintColor = selected ? UIColor.white : UIColor.darkGray
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.cornerRadius = 5.0
        return cell

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
        print(allEvents.count)
        return allEvents.count
    }
    //controls info related to each cell 
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell {
        //c2
        print("entered cell for item at")
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
