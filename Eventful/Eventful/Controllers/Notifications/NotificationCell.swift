//
//  NotificationCell.swift
//  Eventful
//
//  Created by Shawn Miller on 2/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class NotificationCell: UICollectionViewCell {
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
        //        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTransition)))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        label.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
