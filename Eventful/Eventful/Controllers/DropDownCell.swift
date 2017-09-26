//
//  DropDownCell.swift
//  Eventful
//
//  Created by Shawn Miller on 9/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class DropDownCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet{
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            iconImageVIew.tintColor = isHighlighted ? UIColor.white : UIColor.darkGray

        }
    }
    
    var dropDown: ImageAndTitleItem?{
        didSet{
            nameLabel.text = dropDown?.name
            
            if let imageName = dropDown?.imageName{
                iconImageVIew.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                iconImageVIew.tintColor = UIColor.darkGray

            }
        }
    }
    
    override  init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(nameLabel)
        addSubview(iconImageVIew)
        addConstraintsWithFormatt("H:|-8-[v0(20)]-8-[v1]|", views: iconImageVIew,nameLabel)
        addConstraintsWithFormatt("V:|[v0]|", views: nameLabel)
    addConstraintsWithFormatt("V:[v0(20)]", views: iconImageVIew)
        addConstraint(NSLayoutConstraint(item: iconImageVIew, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
       // nameLabel.text = "Seize The Day"
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        return nameLabel
    }()
    
    let iconImageVIew: UIImageView = {
       let iconImageView = UIImageView()
      //  iconImageView.image = UIImage(named: "summer")
        iconImageView.contentMode = .scaleAspectFill
        return iconImageView
    }()
}
