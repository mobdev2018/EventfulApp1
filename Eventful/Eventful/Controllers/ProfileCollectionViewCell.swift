//
//  ProfileCollectionViewCell.swift
//  Eventful
//
//  Created by Shawn Miller on 11/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    public var imageView:CustomImageView!
    public var bottomBar:UIView!
    
    var user: User?{
        didSet {
            setupProfileImage()
            //  userNameLabel.text = user?.username
           // setupUserInteraction()
        }
    }
    
    
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
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.imageView)
        NSLayoutConstraint.activateViewConstraints(self.imageView, inSuperView: self, withLeading: nil, trailing: nil, top: 0, bottom: nil, width: 36.0, height: nil)
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: self.imageView, superView: self)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.imageView, secondView: self.bottomBar, andSeparation: 0.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      //  imageView.layer.cornerRadius = 100/2
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    
    fileprivate func setupProfileImage() {

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
                self.imageView.image = image
            }
            }.resume()
    }
    
}
