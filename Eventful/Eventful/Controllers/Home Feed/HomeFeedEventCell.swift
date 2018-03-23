//
//  HomeFeedEventCell.swift
//  Eventful
//
//  Created by Shawn Miller on 3/21/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class HomeFeedEventCell: BaseRoundedCardCell {
    
    var event: Event? {
        didSet{
            guard let currentEvent = event else {
                return
            }
            guard let url = URL(string: currentEvent.currentEventImage) else { return }
            backgroundImageView.af_setImage(withURL: url)
            
        }
    }
    
    public var backgroundImageView: CustomImageView = {
        let firstImage = CustomImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleToFill
        firstImage.layer.cornerRadius = 5
        return firstImage
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        backgroundColor = .clear
        setCellShadow() 
        addSubview(backgroundImageView)
        backgroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
}
