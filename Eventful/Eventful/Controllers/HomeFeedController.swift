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

class HomeFeedController: UIViewController, UIGestureRecognizerDelegate {
    // let dropDownLauncher = DropDownLauncher()
    var isFinishedPaging = false
    let detailView = EventDetailViewController()
    let refreshControl = UIRefreshControl()
    var emptyLabel: UILabel?
    var allEvents = [Event]()
    //will containt array of event keys
    var eventKeys = [String]()
    let customCellIdentifier = "customCellIdentifier"
    
    fileprivate var collectionView:UICollectionView!
    fileprivate var topView:CustomCell!
//    var grideLayout = GridLayout(numberOfColumns: 2)
    lazy var dropDownLauncer : DropDownLauncher = {
        let launcer = DropDownLauncher()
        launcer.homeFeed = self
        return launcer
    }()
    let paginationHelper = PaginationHelper<Event>(serviceMethod: PostService.showEvent)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        //  self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(handleDropDownMenu))
        self.navigationItem.leftBarButtonItem = backButton
        self.configure()
        reloadHomeFeed()
    }
    
    private func configure(){
        func configureViews(){
            self.topView = CustomCell(frame: .zero)
            self.topView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.topView)
            NSLayoutConstraint.activateViewConstraints(self.topView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: self.view.bounds.size.height/2)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topLayoutGuide, secondView: self.topView, andSeparation: 0.0)
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            self.collectionView.backgroundColor = .white
            self.view.backgroundColor = .white
            self.view.addSubview(self.collectionView)
            NSLayoutConstraint.activateViewConstraints(self.collectionView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topView, secondView: self.collectionView, andSeparation: 0.0)
            _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.collectionView, secondView: self.bottomLayoutGuide, andSeparation: 0.0)
        }
        
        func configureHeaderCell(){
            self.collectionView.register(CustomCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        }
        configureViews()
        configureHeaderCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(self.collectionView!, delay: 50.0)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
//    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
//        if let navigationController = navigationController as? ScrollingNavigationController {
//            navigationController.showNavbar(animated: true)
//        }
//        return true
//    }
    
    
    
    func handleDropDownMenu(){
        dropDownLauncer.showDropDown()
    }
    //will query by selected category
    func categoryFetch(dropDown: DropDown){
        navigationItem.title = dropDown.name
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
            self.topView.nameLabel.text = allEvents[0].currentEventName
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
}


// MARK: - UICollectionViewDelegateFlowLayout
extension HomeFeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath){
            detailView.eventImage = allEvents[indexPath.row].currentEventImage
            detailView.eventName = allEvents[indexPath.row].currentEventName
            //  print("Look here for event name")
            // print(detailView.eventName)
            detailView.eventDescription = allEvents[indexPath.row].currentEventDescription
            detailView.eventStreet = allEvents[indexPath.row].currentEventStreetAddress
            detailView.eventCity = allEvents[indexPath.row].currentEventCity
            detailView.eventState = allEvents[indexPath.row].currentEventState
            detailView.eventZip = allEvents[indexPath.row].currentEventZip
            detailView.eventKey = allEvents[indexPath.row].key!
            detailView.eventPromo = allEvents[indexPath.row].currentEventPromo!
            detailView.eventDate = allEvents[indexPath.row].currentEventDate!
            detailView.eventTime = allEvents[indexPath.row].currentEventTime!
            detailView.currentEvent = allEvents[indexPath.row]
            present(detailView, animated: true, completion: nil)
            //self.navigationController?.pushViewController(detailView, animated: true)
            
        }
        print("Cell \(indexPath.row) selected")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/2.2, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item >= allEvents.count - 1 {
            // print("paginating for post")
            paginationHelper.paginate(completion: { [unowned self] (events) in
                self.allEvents.append(contentsOf: events)
                
                DispatchQueue.main.async {
                    self.reloadCollection()
                }
            })
        }
        else{
            print("Not paginating")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeFeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEvents.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCell
        let model = allEvents[indexPath.item + 1]
        let imageURL = URL(string: model.currentEventImage)
        let dateComponents = self.getDayAndMonthFromEvent(model)
        customCell.dayLabel.text = dateComponents.0
        customCell.monthLabel.text = dateComponents.1
        customCell.calenderUnit.backgroundColor = UIColor.orange
        customCell.backgroundImageView.af_setImage(withURL: imageURL!)
        customCell.nameLabel.text = model.currentEventName
        customCell.flipToSmallWidth(labelWidth: self.view.bounds.size.width/2.2 - 40.0)
        return customCell
    }
}

//responsible for populating each cell with content
// MARK: - Custom Cell

class CustomCell: UICollectionViewCell {
    
    let backgroundImageView: UIImageView = {
        let firstImage = UIImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleAspectFill
        //        firstImage.layer.masksToBounds = true
        return firstImage
    }()
    
    public var nameLabel:UILabel!
    public var nameLabelLeading:NSLayoutConstraint!
    public var nameLabelWidth:NSLayoutConstraint!
    public var nameLabelHeight:NSLayoutConstraint!

    public var calenderToNameLabel:NSLayoutConstraint!

    public var calenderUnit:UIView!
    public var calenderUnitBottom:NSLayoutConstraint!

    public var dayLabel:UILabel!
    public var monthLabel:UILabel!
    
    func setupViews() {
        self.addSubview(self.backgroundImageView)
        self.backgroundColor = UIColor.white

        NSLayoutConstraint.activateViewConstraints(self.backgroundImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
        
        self.calenderUnit = UIView()
        self.calenderUnit.layer.cornerRadius = 5.0
        self.calenderUnit.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.calenderUnit)
        self.dayLabel = UILabel()
        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dayLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        self.dayLabel.textColor = .white
        self.dayLabel.textAlignment = .center
        self.calenderUnit.addSubview(self.dayLabel)
        NSLayoutConstraint.activateViewConstraints(self.dayLabel, inSuperView: self.calenderUnit, withLeading: 0.0, trailing: 0.0, top: 5.0, bottom: nil, width: nil, height: 25.0)
        
        self.monthLabel = UILabel()
        self.monthLabel.translatesAutoresizingMaskIntoConstraints = false
        self.monthLabel.font = UIFont.systemFont(ofSize: 15.0)
        self.monthLabel.textColor = .white
        self.monthLabel.textAlignment = .center
        self.calenderUnit.addSubview(self.monthLabel)
        NSLayoutConstraint.activateViewConstraints(self.monthLabel, inSuperView: self.calenderUnit, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.dayLabel, secondView: self.monthLabel, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateHeightConstraint(view: self.dayLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)
        
        NSLayoutConstraint.activateViewConstraints(self.calenderUnit, inSuperView: self, withLeading: 20.0, trailing: nil, top: nil, bottom: nil, width: 60.0, height: 60.0)
        self.calenderUnitBottom = NSLayoutConstraint.activateBottomConstraint(withView: self.calenderUnit, superView: self, andSeparation: 20.0)
        
        self.nameLabel = UILabel()
        self.nameLabel.numberOfLines = 2
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        self.nameLabel.textColor = .white
        self.nameLabel.shadowColor = UIColor.gray
        self.nameLabel.shadowOffset = CGSize(width: 1, height: -2)
        self.addSubview(self.nameLabel)
        //variable leading
        self.nameLabelLeading = NSLayoutConstraint.activateLeadingConstraint(withView: self.nameLabel, superView: self, andSeparation: 20.0)
        //variable width
        self.nameLabelWidth = NSLayoutConstraint.activateWidthConstraint(view: self.nameLabel, withWidth: min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)/3)
        //variable bottom
        self.calenderToNameLabel = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.calenderUnit, secondView: self.nameLabel, andSeparation: 20.0)
        //variable height
        self.nameLabelHeight = NSLayoutConstraint.activateHeightConstraint(view: self.nameLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)
    }
    
    public func flipToFullWidth(labelWidth width:CGFloat) {
        self.flipToFullWidthState(true, withLabelWidth: width)
    }
    
    public func flipToSmallWidth(labelWidth width:CGFloat) {
        self.flipToFullWidthState(false, withLabelWidth: width)
    }
    
    private func flipToFullWidthState(_ flag:Bool, withLabelWidth width:CGFloat) {
        self.nameLabelWidth.constant = width
        if flag {
            self.calenderUnitBottom.constant = -20.0
            self.nameLabelLeading.constant = 100.0
            self.calenderToNameLabel.constant = -60.0
            self.nameLabelHeight.constant = 60.0
        }
        else {
            self.calenderUnitBottom.constant = -80.0
            self.nameLabelLeading.constant = 20.0
            self.calenderToNameLabel.constant = 20.0
            self.nameLabelHeight.constant = 1.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
}

