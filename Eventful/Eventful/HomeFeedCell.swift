//
//  HomeFeedCell.swift
//  Eventful
//
//  Created by Devanshu Saini on 22/09/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class HomeFeedCell: UICollectionViewCell {
    
    let backgroundImageView: UIImageView = {
        let firstImage = UIImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleAspectFill
        //        firstImage.layer.masksToBounds = true
        return firstImage
    }()
    
    public var nameLabel:UILabel!
    public var nameLabelLeading:NSLayoutConstraint!
    public var nameLabelWidth:NSLayoutConstraint!
    public var nameLabelHeight:NSLayoutConstraint!
    
    public var calenderToNameLabel:NSLayoutConstraint!
    
    public var calenderUnit:UIView!
    public var calenderUnitBottom:NSLayoutConstraint!
    
    public var dayLabel:UILabel!
    public var monthLabel:UILabel!
    
    public var overlayButton:UIButton!
    
    func setupViews() {
        self.addSubview(self.backgroundImageView)
        self.backgroundColor = UIColor.white
        
        NSLayoutConstraint.activateViewConstraints(self.backgroundImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
        
        self.calenderUnit = UIView()
        self.calenderUnit.layer.cornerRadius = 5.0
        self.calenderUnit.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.calenderUnit)
        NSLayoutConstraint.activateViewConstraints(self.calenderUnit, inSuperView: self, withLeading: 15.0, trailing: nil, top: nil, bottom: nil, width: 50.0, height: 50.0)
        self.calenderUnitBottom = NSLayoutConstraint.activateBottomConstraint(withView: self.calenderUnit, superView: self, andSeparation: 15.0)
        
        self.dayLabel = UILabel()
        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dayLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        self.dayLabel.textColor = .white
        self.dayLabel.textAlignment = .center
        self.calenderUnit.addSubview(self.dayLabel)
        NSLayoutConstraint.activateViewConstraints(self.dayLabel, inSuperView: self.calenderUnit, withLeading: 0.0, trailing: 0.0, top: 5.0, bottom: nil, width: nil, height: 25.0)
        
        self.monthLabel = UILabel()
        self.monthLabel.translatesAutoresizingMaskIntoConstraints = false
        self.monthLabel.font = UIFont.systemFont(ofSize: 15.0)
        self.monthLabel.textColor = .white
        self.monthLabel.textAlignment = .center
        self.calenderUnit.addSubview(self.monthLabel)
        NSLayoutConstraint.activateViewConstraints(self.monthLabel, inSuperView: self.calenderUnit, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.dayLabel, secondView: self.monthLabel, andSeparation: -5.0)
        _ = NSLayoutConstraint.activateHeightConstraint(view: self.dayLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)
        
        
        
        self.nameLabel = UILabel()
        self.nameLabel.numberOfLines = 2
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightSemibold)
        self.nameLabel.textColor = .white
        self.nameLabel.shadowColor = UIColor.gray
        self.nameLabel.shadowOffset = CGSize(width: 1, height: -2)
        self.addSubview(self.nameLabel)
        //variable leading
        self.nameLabelLeading = NSLayoutConstraint.activateLeadingConstraint(withView: self.nameLabel, superView: self, andSeparation: 15.0)
        //variable width
        self.nameLabelWidth = NSLayoutConstraint.activateWidthConstraint(view: self.nameLabel, withWidth: min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)/3)
        //variable bottom
        self.calenderToNameLabel = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.calenderUnit, secondView: self.nameLabel, andSeparation: 15.0)
        //variable height
        self.nameLabelHeight = NSLayoutConstraint.activateHeightConstraint(view: self.nameLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)
        
        self.overlayButton = UIButton(type: .custom)
        self.overlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.overlayButton)
        NSLayoutConstraint.activateViewConstraints(self.overlayButton, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
    }
    
    public func flipToFullWidth(labelWidth width:CGFloat) {
        self.flipToFullWidthState(true, withLabelWidth: width)
    }
    
    public func flipToSmallWidth(labelWidth width:CGFloat) {
        self.flipToFullWidthState(false, withLabelWidth: width)
    }
    
    private func flipToFullWidthState(_ flag:Bool, withLabelWidth width:CGFloat) {
        self.nameLabelWidth.constant = width
        if flag {
            self.calenderUnitBottom.constant = -15.0
            self.nameLabelLeading.constant = 80.0
            self.calenderToNameLabel.constant = -50.0
            self.nameLabelHeight.constant = 50.0
        }
        else {
            self.calenderUnitBottom.constant = -70.0
            self.nameLabelLeading.constant = 15.0
            self.calenderToNameLabel.constant = 10.0
            self.nameLabelHeight.constant = 1.0
        }
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
