//
//  EventSearchCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class EventSearchCell: UICollectionViewCell {
    var event: Event?{
        didSet{
            eventNameLabel.text = event?.currentEventName.uppercased()
            
            guard let eventImageURL = event?.currentEventImage else{
                return
            }
            
            eventImageView.loadImage(urlString: eventImageURL)
        }
    }
    let eventImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let eventNameLabel : UILabel = {
       let label = UILabel()
        label.text = "EventName"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(eventImageView)
        addSubview(eventNameLabel)
        eventImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        eventImageView.layer.cornerRadius = 50/2
        eventNameLabel.anchor(top: topAnchor, left: eventImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: eventNameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
