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
import AMScrollingNavbar

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
    let refreshControl = UIRefreshControl()
    var emptyLabel: UILabel?
    var allEvents = [Event]()
    //will containt array of event keys
    var eventKeys = [String]()
    let eventCellIdentifier = "customCellIdentifier"
    let topCell = "topCell"
    
    fileprivate var collectionView:UICollectionView!
    fileprivate var topView:HomeFeedCell!
    fileprivate var topCollectionView:UICollectionView!
    //    var grideLayout = GridLayout(numberOfColumns: 2)
    //    lazy var dropDownLauncer : DropDownLauncher = {
    //        let launcer = DropDownLauncher()
    //        launcer.homeFeed = self
    //        return launcer
    //    }()
    let paginationHelper = PaginationHelper<Event>(serviceMethod: PostService.showEvent)
    
    let dropDown: [ImageAndTitleItem] = {
        return [ImageAndTitleItem(name: "Home", imageName: "home"), ImageAndTitleItem(name: "Seize The Night", imageName: "night"), ImageAndTitleItem(name: "Seize The Day", imageName: "summer"), ImageAndTitleItem(name: "Dress To Impress", imageName: "suit"), ImageAndTitleItem(name: "I Love College", imageName: "college"), ImageAndTitleItem(name: "21 & Up", imageName: "21")]
    }()
    
    fileprivate var selectedTopIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        //  self.navigationItem.hidesBackButton = true
        
        self.configure()
        reloadHomeFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //        if let navigationController = self.navigationController as? ScrollingNavigationController {
        //            navigationController.followScrollView(self.collectionView!, delay: 50.0)
        //        }
        if self.selectedTopIndex == nil {
            self.performActionOnTopItemSelect(at: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //        if let navigationController = navigationController as? ScrollingNavigationController {
        //            navigationController.stopFollowingScrollView()
        //        }
    }
    
    private func configure(){
        func configureViews(){
            let topLayout = UICollectionViewFlowLayout()
            topLayout.scrollDirection = .horizontal
            self.topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: topLayout)
            self.topCollectionView.tag = 0
            self.topCollectionView.backgroundColor = .white
            self.topCollectionView.dataSource = self
            self.topCollectionView.delegate = self
            self.topCollectionView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.topCollectionView)
            NSLayoutConstraint.activateViewConstraints(self.topCollectionView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 50.0)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topLayoutGuide, secondView: self.topCollectionView, andSeparation: 0.0)
            
            self.topView = HomeFeedCell(frame: .zero)
            self.topView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.topView)
            self.topView.overlayButton.tag = 0
            let actions = self.topView.overlayButton.actions(forTarget: self, forControlEvent: .touchUpInside)
            if actions == nil || actions?.count == 0 {
                self.topView.overlayButton.addTarget(self, action: #selector(self.handleTapOnItem(_:)), for: .touchUpInside)
            }
            NSLayoutConstraint.activateViewConstraints(self.topView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: self.view.bounds.size.height/2 - 50.0)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topCollectionView, secondView: self.topView, andSeparation: 0.0)
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.collectionView.tag = 1
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            self.collectionView.backgroundColor = .white
            self.view.backgroundColor = .white
            self.view.addSubview(self.collectionView)
            NSLayoutConstraint.activateViewConstraints(self.collectionView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topView, secondView: self.collectionView, andSeparation: 0.0)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.collectionView, secondView: self.bottomLayoutGuide, andSeparation: 0.0)
        }
        
        func configureCollectionCell(){
            self.collectionView.register(HomeFeedCell.self, forCellWithReuseIdentifier: eventCellIdentifier)
            self.topCollectionView.register(DropDownCell.self, forCellWithReuseIdentifier: topCell)
        }
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
    
    //    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    //        if let navigationController = navigationController as? ScrollingNavigationController {
    //            navigationController.showNavbar(animated: true)
    //        }
    //        return true
    //    }
    
    //will query by selected category
    func categoryFetch(dropDown: ImageAndTitleItem){
        navigationItem.title = dropDown.name
        paginationHelper.category = dropDown.name
        self.configure()
        reloadHomeFeed()
    }
    
    func reloadHomeFeed() {
        self.paginationHelper.reloadData(completion: { [unowned self] (events) in
            self.allEvents = events
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            DispatchQueue.main.async {
                self.reloadCollection()
            }
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //will make surepictures keep same orientation even if you flip screen
    // will most likely lock into portrait mode but still good to have
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func showLeftView(sender: AnyObject?){
        print("Button Pressed")
        // sideMenuController?.leftViewController = LeftViewController()
        //sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    fileprivate func reloadCollection() {
        if allEvents.count > 0 {
            let imageURL = URL(string: allEvents[0].currentEventImage)
            let dateComponents = self.getDayAndMonthFromEvent(allEvents[0])
            self.topView.dayLabel.text = dateComponents.0
            self.topView.monthLabel.text = dateComponents.1
            self.topView.calenderUnit.backgroundColor = UIColor.blue
            self.topView.backgroundImageView.af_setImage(withURL: imageURL!)
            self.topView.nameLabel.text = allEvents[0].currentEventName.capitalized
            self.topView.flipToFullWidth(labelWidth: self.view.bounds.size.width - 120.0)
        }
        self.collectionView.reloadData()
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
    
    @objc fileprivate func handleTapOnItem(_ sender:UIButton) {
        if self.allEvents.count <= sender.tag {
            return
        }
        let model = self.allEvents[sender.tag]
        detailView.eventKey = model.key!
        detailView.eventPromo = model.currentEventPromo!
        detailView.currentEvent = model
        present(detailView, animated: true, completion: nil)
        //debugPrint("Tap at index: \(sender.tag)")
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension HomeFeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            self.performActionOnTopItemSelect(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let cellWith = self.dropDown[indexPath.item].name!.textRect(withFont: UIFont.systemFont(ofSize: 13), andHeight: 20.0).size.width + 44.0
            return CGSize(width: cellWith, height: collectionView.bounds.size.height - 20)
        }
        else {
            return CGSize(width: collectionView.bounds.size.width/2.2, height: collectionView.bounds.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == 0 {
            return UIEdgeInsetsMake(10.0, 15.0, 10.0, 0.0)
        }
        else {
            return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 0 {
            return 15.0
        }
        else {
            return 2.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 0 {
            return 15.0
        }
        else {
            return 0.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            print(indexPath.item)
            print(allEvents.count - 1)
            if indexPath.item >= allEvents.count - 1 {
                // print("paginating for post")
                paginationHelper.paginate(completion: { [unowned self] (events) in
                    self.allEvents.append(contentsOf: events)
                    DispatchQueue.main.async {
                        self.reloadCollection()
                    }
                })
            }else{
                //debugPrint("Not paginating")
            }
           
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeFeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return dropDown.count
        }
        else {
            return allEvents.count - 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
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
        else {
            let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: eventCellIdentifier, for: indexPath) as! HomeFeedCell
            let model = allEvents[indexPath.item + 1]
            let imageURL = URL(string: model.currentEventImage)
            let dateComponents = self.getDayAndMonthFromEvent(model)
            customCell.dayLabel.text = dateComponents.0
            customCell.monthLabel.text = dateComponents.1
            customCell.calenderUnit.backgroundColor = UIColor.orange
            customCell.backgroundImageView.af_setImage(withURL: imageURL!)
            customCell.nameLabel.text = model.currentEventName.capitalized
            customCell.flipToSmallWidth(labelWidth: self.view.bounds.size.width/2.2 - 40.0)
            customCell.overlayButton.tag = indexPath.item + 1
            let actions = customCell.overlayButton.actions(forTarget: self, forControlEvent: .touchUpInside)
            if actions == nil || actions?.count == 0 {
                customCell.overlayButton.addTarget(self, action: #selector(self.handleTapOnItem(_:)), for: .touchUpInside)
            }
            return customCell
        }
    }
}

