    //
    //  ProfileeViewController.swift
    //  Eventful
    //
    //  Created by Shawn Miller on 7/30/17.
    //  Copyright © 2017 Make School. All rights reserved.
    //
    
    import UIKit
    import SwiftyJSON
    import  AlamofireImage
    import Alamofire
    import AlamofireNetworkActivityIndicator
    import Foundation
    import Firebase
    import FirebaseDatabase
    import FirebaseStorage
    
    
    class ProfileeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
        var profileHandle: DatabaseHandle = 0
        var profileRef: DatabaseReference?
        let cellID = "cellID"
        let profileSetupTransition = AlterProfileViewController()
        let settingView = SettingsViewController()
        var userEvents = [Event]()
        var userId: String?
        var user: User?
        var emptyLabel: UILabel?
        
        var currentUserName: String = ""
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            collectionView?.backgroundColor = UIColor.white
            let user = self.user ?? User.current
            
            profileHandle = UserService.observeProfile(for: user) { [unowned self](ref, user, events) in
                self.profileRef = ref
                self.user = user
                self.userEvents = events
                // self.jobs = allJobs
                // self.reciepts = allReciepts
                
                // print(self.userEvents)
                //  print(self.reciepts)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            }
            
            // fetchUser()
            
            self.collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
            
            self.navigationController?.isNavigationBarHidden = true
            
            collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
            
            collectionView?.register(EventsAttendingCell.self, forCellWithReuseIdentifier: cellID)
            //        fetchEvents()
            collectionView?.alwaysBounceVertical = true
            
            
            
        }
        
        deinit {
            profileRef?.removeObserver(withHandle: profileHandle)
        }
        
        
        
        override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! UserProfileHeader
            header.profileeSettings.addTarget(self, action: #selector(profileSettingsTapped), for: .touchUpInside)
            header.settings.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
            header.user = self.user
            header.backButton.addTarget(self, action: #selector(GoBack), for: .touchUpInside)
            return header
        }
        
        @objc func GoBack(){
            dismiss(animated: true, completion: nil)
        }
        
        @objc func settingsButtonTapped(){
            present(settingView, animated: true, completion: nil)
            //        self.navigationController?.pushViewController(settingView, animated: true)
            
        }
        
        @objc func profileSettingsTapped(){
            present(profileSetupTransition, animated: true, completion: nil)
            //        self.navigationController?.pushViewController(profileSetupTransition, animated: true)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: view.frame.width, height: 200)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.isNavigationBarHidden = true
            
            self.collectionView?.reloadData()
        }
        
        
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            if userEvents.isEmpty == false {
                self.collectionView?.backgroundView = nil
                return userEvents.count
                
            } else{
                emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                paragraph.alignment = .center
                
                let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightGray, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): paragraph]
                let myAttrString = NSAttributedString(string:  "Go Attend Some Events", attributes: attributes)

                emptyLabel?.attributedText = myAttrString
                emptyLabel?.textAlignment = .center
                self.collectionView?.backgroundView = emptyLabel
                return 0
            }
        }
        
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (view.frame.width - 2)/3
            return CGSize(width: width, height: width)
            
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! EventsAttendingCell
            cell.layer.cornerRadius = 70/2
            cell.event = userEvents[indexPath.item]
            
            return cell
        }
        
    }
    
    
