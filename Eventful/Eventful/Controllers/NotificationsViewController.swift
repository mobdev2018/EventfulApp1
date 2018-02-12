//
//  NotificationsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 1/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class NotificationsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var emptyLabel: UILabel?
    var messagesRef: DatabaseReference?
    var notifications = [Notifications]()
    let users = Users.sharedInstance.allUsers
    
    var notificationCellID = "notificationCellID"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        //move this to numberOfItems once datasource and delegate are created and handled
        emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightGray, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): paragraph]
        let myAttrString = NSAttributedString(string:  "No Notifications to Show", attributes: attributes)
        
        emptyLabel?.attributedText = myAttrString
        emptyLabel?.textAlignment = .center
        self.collectionView?.backgroundView = emptyLabel
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(NotificationCell.self, forCellWithReuseIdentifier: notificationCellID)
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchNotificationData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //will fetch the notifications from the database and append them to an array
    fileprivate func fetchNotificationData(){
        self.notifications.removeAll()
        messagesRef = Database.database().reference().child("Notifications").child(User.current.uid)
        let query = messagesRef?.queryOrderedByKey()
        query?.observe(.value, with: { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            allObjects.forEach({ (snapshot) in
                self.notifications.append(Notifications.init(snapshot: snapshot)!)
                self.notifications.reverse()
                self.emptyLabel?.isHidden = true
                self.collectionView?.reloadData()
            })
        })
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items

        return self.notifications.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationCellID, for: indexPath) as! NotificationCell
        
        cell.notification = self.notifications[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 50)
        let dummyCell = NotificationCell(frame: frame)
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, estimatedSize.height)
        return  CGSize(width: collectionView.frame.size.width, height: height)
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If user taps on comment, it will take user to the comment screen
        if (self.notifications[indexPath.row].notiType == "comment"){
            let commentDetail = NewCommentsViewController()
            commentDetail.eventKey = self.notifications[indexPath.item].eventKey
            present(commentDetail, animated: true, completion: nil)
        }
    }

}
