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
        // selectPicture.layer.cornerRadius = selectPicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        //selectPicture.layer.cornerRadius = selectPicture.frame.size.width/2
        profilePicture.contentMode = .scaleAspectFill
        profilePicture.isUserInteractionEnabled = true
        profilePicture.layer.shouldRasterize = true
        // will allow you to add a target to an image click
        profilePicture.layer.masksToBounds = true
        return profilePicture
    }()
    
    
    //creatas a UILabel
  
    lazy var statsLabel : UILabel = {
       let statsLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Score", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        statsLabel.attributedText = attributedText
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .center
        return statsLabel
    }()
    
    lazy var followersLabel : UILabel = {
        let followersLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Followers", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        followersLabel.attributedText = attributedText
        followersLabel.numberOfLines = 0
        followersLabel.textAlignment = .center
        return followersLabel
    }()
    
    
    lazy var followingLabel : UILabel = {
        let followingLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Following", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        followingLabel.attributedText = attributedText
        followingLabel.numberOfLines = 0
        followingLabel.textAlignment = .center
        return followingLabel
    }()
    
    
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
        let follow = UIButton(type: .system)
        follow.setImage(#imageLiteral(resourceName: "icons8-Unchecked Checkbox-64").withRenderingMode(.alwaysOriginal), for: .normal)
        follow.setTitleColor(.black, for: .normal)
        return follow
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
            
        } else{
             let userStackView = UIStackView(arrangedSubviews: [backButton, followButton])
            userStackView.distribution = .fillEqually
            userStackView.axis = .vertical
            addSubview(userStackView)
            userStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
            followButton.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        }
    }
    
    func handleFollow(){
        print("function handled")
    }
    
    
    fileprivate func setupToolBar(){
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackview = UIStackView(arrangedSubviews: [statsLabel,followersLabel,followingLabel])
        stackview.distribution = .fillEqually
        addSubview(stackview)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        stackview.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 60)
        
        topDividerView.anchor(top: stackview.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackview.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    
    fileprivate func setupProfileImage() {
        
        
        print("Did set username\(user?.username)")
        
        
        guard let profileImageUrl = user?.profilePic else { return }
        
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
    
    fileprivate func setupProfileStack(){
        let profileStackView = UIStackView(arrangedSubviews: [profileImage])
        addSubview(profileStackView)
        profileStackView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
//        addSubview(profileImage)
//        profileImage.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 135, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
//        profileImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        profileImage.layer.cornerRadius = 100/2
    
        setupToolBar()
        setupProfileStack()

       
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
