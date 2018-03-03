//
//  NotificationsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 1/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

private let reuseIdentifier = "Cell"

class NotificationsViewController: UIViewController,NotificationsSectionDelegate {
    
    var emptyLabel: UILabel?
    //array of notifications which will be loaded by a service function
    var notifs = [Notifications]()
    var notifRef: DatabaseReference?
    
    //This creates a lazily-initialized variable for the IGListAdapter. The initializer requires three parameters:
    //1 updater is an object conforming to IGListUpdatingDelegate, which handles row and section updates. IGListAdapterUpdater is a default implementation that is suitable for your usage.
    //2 viewController is a UIViewController that houses the adapter. This view controller is later used for navigating to other view controllers.
    //3 workingRangeSize is the size of the working range, which allows you to prepare content for sections just outside of the visible frame.
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    
    // 1 IGListKit uses IGListCollectionView, which is a subclass of UICollectionView, which patches some functionality and prevents others.
    let collectionView: UICollectionView = {
        // 2 This starts with a zero-sized rect since the view isn’t created yet. It uses the UICollectionViewFlowLayout just as the ClassicFeedViewController did.
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        // 3 The background color is set to white
        view.backgroundColor = UIColor.white
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //add line seperator to distance collectionView from top tab bar
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.black
        view.addSubview(lineSeparatorView)
         lineSeparatorView.anchor(top:view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2.5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        //will add the collectionView for the iglistkit 
        collectionView.frame = CGRect.init(x: 0, y: 5, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-40)
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        adapter.collectionView = collectionView
        adapter.dataSource = self
        collectionView.register(NotificationCell.self, forCellWithReuseIdentifier: "NotificaationCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchNotifs()
    }
    

    
    fileprivate func fetchNotifs(){
        NotificationService.fetchUserNotif { (currentUserNotifs) in
            print("user has \(currentUserNotifs.count) notifications")
            self.notifs = currentUserNotifs
            self.notifs = self.sortNotifs(notifArray: self.notifs)
            self.adapter.performUpdates(animated: true)
        }
    }
    
    //will sort the notifications based off of timeStamp
    fileprivate func sortNotifs(notifArray: [Notifications]) -> [Notifications]{
        var tempNotifArray = notifArray
        tempNotifArray.sort(by: { (reply1, reply2) -> Bool in
            return reply1.timeStamp?.compare(reply2.timeStamp!) == .orderedDescending
        })
        return tempNotifArray
    }
    
    func NotificationsSectionUpdared(sectionController: NotificationsSectionController) {
        self.adapter.performUpdates(animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NotificationsViewController: ListAdapterDataSource {
    // 1 objects(for:) returns an array of data objects that should show up in the collection view. loader.entries is provided here as it contains the journal entries.
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let items:[ListDiffable] = notifs
        //print("comments = \(comments)")
        return items
    }
    
    
    
    
    // 2 For each data object, listAdapter(_:sectionControllerFor:) must return a new instance of a section controller. For now you’re returning a plain IGListSectionController to appease the compiler — in a moment, you’ll modify this to return a custom journal section controller.
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        //the comment section controller will be placed here but we don't have it yet so this will be a placeholder
        let sectionController = NotificationsSectionController()
        sectionController.delegate = self
        
        return sectionController
    }
    
    // 3 emptyView(for:) returns a view that should be displayed when the list is empty. NASA is in a bit of a time crunch, so they didn’t budget for this feature.
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = UIView()
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightGray, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): paragraph]
        let myAttrString = NSAttributedString(string:  "No Notifications to Show", attributes: attributes)
        emptyLabel.attributedText = myAttrString
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        view.backgroundColor = UIColor.white
        return view
    }
}
