//
//  NewHomeFeedControllerViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/25/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftLocation
import CoreLocation
import AMScrollingNavbar

class NewHomeFeedControllerViewController: UIViewController {
    let detailView = EventDetailViewController()
    var allEvents = [Event]()
    let customCellIdentifier1 = "customCellIdentifier1"
    var grideLayout = GridLayout(numberOfColumns: 2)
    let refreshControl = UIRefreshControl()
    var newHomeFeed: NewHomeFeedControllerViewController?
      let paginationHelper = PaginationHelper<Event>(serviceMethod: PostService.showEvent)
    lazy var dropDownLauncer : DropDownLauncher = {
        let launcer = DropDownLauncher()
        launcer.newHomeFeed = self
        return launcer
    }()
    
    // 1 IGListKit uses IGListCollectionView, which is a subclass of UICollectionView, which patches some functionality and prevents others.
    let collectionView: UICollectionView = {
        // 2 This starts with a zero-sized rect since the view isn’t created yet. It uses the UICollectionViewFlowLayout just as the ClassicFeedViewController did.
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        // 3 The background color is set to white
        view.backgroundColor = UIColor.white
        return view
    }()
    func handleDropDownMenu(){
        dropDownLauncer.showDropDown()
    }
    func configureCollectionView() {
        // add pull to refresh
        refreshControl.addTarget(self, action: #selector(reloadHomeFeed), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    func reloadHomeFeed() {
        self.paginationHelper.reloadData(completion: { [unowned self] (events) in
            self.allEvents = events
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    func categoryFetch(dropDown: DropDown){
        navigationItem.title = dropDown.name
        paginationHelper.category = dropDown.name
        configureCollectionView()
        reloadHomeFeed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
        navigationItem.title = "Home"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = grideLayout
        collectionView.reloadData()
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: customCellIdentifier1)
        //  self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(handleDropDownMenu))
        self.navigationItem.leftBarButtonItem = backButton
        configureCollectionView()
        reloadHomeFeed()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(self.collectionView, delay: 50.0)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
     func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
        return true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        grideLayout.invalidateLayout()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension NewHomeFeedControllerViewController: UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let selectedEvent = self.imageArray[indexPath.row]
        //let eventDetailVC
        if let cell = collectionView.cellForItem(at: indexPath){
            //  print("Look here for event name")
            // print(detailView.eventName)
            detailView.eventKey = allEvents[indexPath.row].key!
            detailView.eventPromo = allEvents[indexPath.row].currentEventPromo!
            detailView.currentEvent = allEvents[indexPath.row]
            present(detailView, animated: true, completion: nil)
            //self.navigationController?.pushViewController(detailView, animated: true)
            
        }
        print("Cell \(indexPath.row) selected")
    }
}

extension NewHomeFeedControllerViewController: UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEvents.count
    }
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier1, for: indexPath) as! CustomCell
        let imageURL = URL(string: allEvents[indexPath.item].currentEventImage)
        print(imageURL ?? "")
        customCell.sampleImage.af_setImage(withURL: imageURL!)
        return customCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section >= allEvents.count - 1 {
            // print("paginating for post")
            paginationHelper.paginate(completion: { [unowned self] (events) in
                self.allEvents.append(contentsOf: events)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
        }else{
            print("Not paginating")
        }
    }

}


extension NewHomeFeedControllerViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == 1 {
            return CGSize(width: view.frame.width, height: grideLayout.itemSize.height)
        }else{
            return grideLayout.itemSize
        }
    }
}
