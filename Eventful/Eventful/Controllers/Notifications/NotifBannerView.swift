//
//  NotifBannerView.swift
//  Eventful
//
//  Created by Shawn Miller on 3/12/18.
//  Copyright © 2018 Make School. All rights reserved.
//

//custom notification view for in app push notifs
import UIKit
import Foundation

class NotifBannerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //profilePic
    //content:
    var userInfoForNotif: [AnyHashable : Any]?{
        didSet{
            profileImageView.loadImage(urlString: userInfoForNotif!["profilePic"] as! String)
            let attributedText = NSMutableAttributedString(string: userInfoForNotif!["content"] as! String, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10)])
            label.attributedText = attributedText

        }
    }
    //profile image view for the notif banner
     var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(label)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        profileImageView.layer.cornerRadius = 25/2
        label.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 8, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
