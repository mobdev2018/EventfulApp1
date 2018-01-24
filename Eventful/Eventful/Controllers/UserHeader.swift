//
//  UserHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UserProfileHeader: UICollectionViewCell {
    var user: User?{
        didSet {
            setupProfileImage()
            //  userNameLabel.text = user?.username
            setupUserInteraction()
        }
    }
    lazy var profileImage: UIImageView = {
        let profilePicture = UIImageView()
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.clipsToBounds = true
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.isUserInteractionEnabled = true
        profilePicture.layer.shouldRasterize = true
        // will allow you to add a target to an image click
        profilePicture.layer.masksToBounds = true
        return profilePicture
    }()
    lazy var statsLabel : UILabel = {
        let statsLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Score", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        statsLabel.attributedText = attributedText
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .center
        return statsLabel
    }()
//    lazy var followersLabel : UILabel = {
//        let followersLabel = UILabel()
//        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
//        attributedText.append(NSAttributedString(string: "Followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
//        followersLabel.attributedText = attributedText
//        followersLabel.numberOfLines = 0
//        followersLabel.textAlignment = .center
//        return followersLabel
//    }()
//    lazy var followingLabel : UILabel = {
//        let followingLabel = UILabel()
//        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
//        attributedText.append(NSAttributedString(string: "Following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
//        followingLabel.attributedText = attributedText
//        followingLabel.numberOfLines = 0
//        followingLabel.textAlignment = .center
//        return followingLabel
//    }()
    // will be the button that the user clicks to edit there profile settings
    lazy var profileeSettings: UIButton = {
        let profileSetup = UIButton(type: .system)
        profileSetup.setImage(#imageLiteral(resourceName: "icons8-Edit-50").withRenderingMode(.alwaysOriginal), for: .normal)
        profileSetup.setTitleColor(.black, for: .normal)
        return profileSetup
    }()
    lazy var settings: UIButton = {
        let settings = UIButton(type: .system)
        settings.setImage(#imageLiteral(resourceName: "icons8-Settings-50").withRenderingMode(.alwaysOriginal), for: .normal)
        settings.setTitleColor(.black, for: .normal)
        return settings
    }()
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
       // button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        return button
    }()
    lazy var backButton: UIButton = {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "icons8-Back-64"), for: .normal)
        return backButton
    }()
    fileprivate func setupUserInteraction (){
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else{
            return
        }
        guard let uid = user?.uid else{
            return
        }
        
        if currentLoggedInUser == uid {
            let userStackView = UIStackView(arrangedSubviews: [profileeSettings, settings])
            userStackView.distribution = .fillEqually
            userStackView.axis = .vertical
            userStackView.spacing = 10.0
            addSubview(userStackView)
            userStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 90)
            let bottomDividerView = UIView()
            bottomDividerView.backgroundColor = UIColor.lightGray
            addSubview(bottomDividerView)
             bottomDividerView.anchor(top: profileStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            
        } else{
            let userStackView = UIStackView(arrangedSubviews: [backButton])
            userStackView.distribution = .fillEqually
            userStackView.spacing = 10.0
            userStackView.axis = .vertical
            addSubview(userStackView)
            userStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
            addSubview(followButton)
            followButton.anchor(top: profileStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 50, paddingBottom:0 , paddingRight: 50, width: 0, height: 0)
            let bottomDividerView = UIView()
            bottomDividerView.backgroundColor = UIColor.lightGray
              addSubview(bottomDividerView)
             bottomDividerView.anchor(top: followButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUser).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    
                    self.followButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    self.setupFollowStyle()
                }
                
            }, withCancel: { (err) in
                print("Failed to check if following:", err)
            })
            
        }
    }
    
    @objc func didTapFollowButton(){
        print("function handled")
        followButton.isUserInteractionEnabled = false
        let followee = user
        
        
        //will check if the user if being followed or not
        if (followee?.isFollowed)! {
            //will unfollow the user
            FollowService.setIsFollowing(!(followee?.isFollowed)!, fromCurrentUserTo: followee!) { (success) in
                defer {
                    self.followButton.isUserInteractionEnabled = true
                }
                
                guard success else { return }
                followee?.isFollowed = !(followee?.isFollowed)!
                print(followee?.isFollowed ?? "true")
                print("Successfully unfollowed user:", self.user?.username ?? "")
                self.setupFollowStyle()
            }
        }else{
            //will follow the user
            FollowService.setIsFollowing(!(followee?.isFollowed)!, fromCurrentUserTo: followee!) { (success) in
                defer {
                    self.followButton.isUserInteractionEnabled = true
                }
                
                guard success else { return }
                print(followee?.isFollowed ?? "true")
                
                followee?.isFollowed = !(followee?.isFollowed)!
                print(followee?.isFollowed ?? "true")
                print("Successfully followed user: ", self.user?.username ?? "")
                self.followButton.setTitle("Unfollow", for: .normal)
                self.followButton.backgroundColor = .white
                self.followButton.setTitleColor(.black, for: .normal)
            }
            
        }
        
        
    }
    
    fileprivate func setupFollowStyle() {
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.followButton.setTitleColor(.white, for: .normal)
        self.followButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    

    
    
    fileprivate func setupProfileImage() {
        
        
        print("Did set username\(user?.username ?? "")")
        
        
        guard let profileImageUrl = user?.profilePic else {return }
        
        guard let url = URL(string: profileImageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            //check for the error, then construct the image using data
            if let err = err {
                print("Failed to fetch profile image:", err)
                return
            }
            
            //perhaps check for response status of 200 (HTTP OK)
            
            guard let data = data else { return }
            
            let image = UIImage(data: data)
            
            //need to get back onto the main UI thread
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
            
            }.resume()
    }
    
    lazy var profileStackView = UIStackView(arrangedSubviews: [profileImage])
    
    fileprivate func setupProfileStack(){
        addSubview(profileStackView)
        profileStackView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        profileImage.layer.cornerRadius = 100/2
       // setupToolBar()
        setupProfileStack()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
