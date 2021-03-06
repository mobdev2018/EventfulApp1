//
//  NotificationCell.swift
//  Eventful
//
//  Created by Shawn Miller on 2/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
protocol NotificationCellDelegate: class {
    func handleProfileTransition(tapGesture: UITapGestureRecognizer)
}

class NotificationCell: UICollectionViewCell,NotificationCellDelegate {
    weak var delegate: NotificationCellDelegate? = nil
    override var reuseIdentifier : String {
        get {
            return "notificationCellID"
        }
        set {
            // nothing, because only red is allowed
        }
    }
    
    var notification: Notifications?{
        didSet{
            guard let notification = notification else{
                return
            }
            profileImageView.loadImage(urlString: notification.profilePic!)
            
            let attributedText = NSMutableAttributedString(string: notification.content, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
            let timeAgoDisplay = notification.timeStamp?.timeAgoDisplay()
            attributedText.append(NSAttributedString(string: timeAgoDisplay!, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]))
            
            label.attributedText = attributedText
            
            if notification.notiType == "follow"{
                setupUserInteraction()
            }
        }
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTransition)))
        iv.contentMode = .scaleAspectFill
        return iv
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
    
    @objc func didTapFollowButton(){
    print("follow button tapped")
        
    }
    fileprivate func setupUserInteraction (){
        print("Attempting to add follow button")
        print(notification?.receiver?.username as Any)
        addSubview(self.followButton)
        self.followButton.setTitle("Follow", for: .normal)
        followButton.anchor(top: topAnchor, left: label.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 25, paddingRight: 20, width: 0, height: 0)
        
        
            }
    
    
    @objc func handleProfileTransition(tapGesture: UITapGestureRecognizer){
        print("image tapped")
        delegate?.handleProfileTransition(tapGesture: tapGesture)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        label.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
