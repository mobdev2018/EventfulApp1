//
//  ImageCollectionViewCell.swift
//  Eventful
//
//  Created by Devanshu Saini on 23/09/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    public var imageView:CustomImageView!
    public var bottomBar:UIView!
    let notificaitonView = UIView()

    func setupViews() {
        self.bottomBar = UIView()
        self.bottomBar.backgroundColor = .clear
        self.bottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomBar)
        NSLayoutConstraint.activateViewConstraints(self.bottomBar, inSuperView: self, withLeading: nil, trailing: nil, top: nil, bottom: 0.0, width: 40.0, height: 1.5)
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: self.bottomBar, superView: self)
        
        self.imageView = CustomImageView()
        self.imageView.clipsToBounds = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleToFill
        self.addSubview(self.imageView)
        
        notificaitonView.frame = CGRect(x: 20, y: 0, width:10, height: 10)
        notificaitonView.layer.cornerRadius = 10/2
        notificaitonView.clipsToBounds = true
        notificaitonView.isHidden = true
        notificaitonView.backgroundColor = UIColor.red
        self.imageView.addSubview(notificaitonView)
        
        
        //maybe change to nil
        NSLayoutConstraint.activateViewConstraints(self.imageView, inSuperView: self, withLeading: nil, trailing: nil, top: 0, bottom: nil, width: 30, height: 30)
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: self.imageView, superView: self)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.imageView, secondView: self.bottomBar, andSeparation: 0.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
}
