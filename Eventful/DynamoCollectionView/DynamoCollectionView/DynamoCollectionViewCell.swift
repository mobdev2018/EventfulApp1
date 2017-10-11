//
//  DynamoCollectionViewCell.swift
//  DynamoCollectionView
//
//  Created by Thang Pham on 10/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

enum DynamoDisplayMode {
    case Top
    case Normal
}

protocol DynamoCollectionViewCellDelegate: NSObjectProtocol {
    func dynamoCollectionViewCellDidSelect(sender: UICollectionViewCell)
}

public class DynamoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Variables
    var delegate: DynamoCollectionViewCellDelegate?
    
    public var backgroundImageView: CustomImageView = {
        let firstImage = CustomImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleAspectFill
        return firstImage
    }()
    
    public var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.color = UIColor.gray
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    public var title:String? {
        set {
            nameLabel.text = newValue
        }
        get {
            return nameLabel.text
        }
    }
    public var day:String? {
        set {
            dayLabel.text = newValue
        }
        get {
            return dayLabel.text
        }
    }
    public var month:String? {
        set {
            monthLabel.text = newValue
        }
        get {
            return monthLabel.text
        }
    }
    
    override public var tag: Int {
        set {
            super.tag = newValue
            setDisplayMode(newValue == 0 ? .Top : .Normal)
        }
        get {
            return super.tag
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: - Private variables

    private var nameLabel:UILabel!
    private var nameLabelLeading:NSLayoutConstraint!
    private var nameLabelWidth:NSLayoutConstraint!
    private var nameLabelHeight:NSLayoutConstraint!
    private var calenderToNameLabel:NSLayoutConstraint!
    private var calenderUnit:UIView!
    private var calenderUnitBottom:NSLayoutConstraint!
    private var dayLabel:UILabel!
    private var monthLabel:UILabel!
    //private var overlayButton:UIButton!
    
    private func setupViews() {
        
        
        self.addSubview(self.backgroundImageView)
        
        
        self.backgroundColor = UIColor.white
        
        NSLayoutConstraint.activateViewConstraints(self.backgroundImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
        
        self.calenderUnit = UIView()
        self.calenderUnit.layer.cornerRadius = 5.0
        self.calenderUnit.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.calenderUnit)
        NSLayoutConstraint.activateViewConstraints(self.calenderUnit, inSuperView: self, withLeading: 15.0, trailing: nil, top: nil, bottom: nil, width: 45.0, height: 45.0)
        self.calenderUnitBottom = NSLayoutConstraint.activateBottomConstraint(withView: self.calenderUnit, superView: self, andSeparation: 15.0)
        
        self.dayLabel = UILabel()
        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dayLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
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
        self.nameLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delaysTouchesBegan = false
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        
        self.backgroundImageView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activateViewConstraints(self.activityIndicatorView, inSuperView: self.backgroundImageView, withLeading: 0, trailing: 0, top: 0, bottom: 0, width: nil, height: nil)
    }
    
    @objc func handleTap(_ recognizer:UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            delegate?.dynamoCollectionViewCellDidSelect(sender: self)
        default:
            break
        }
    }
    
    private func setDisplayMode(_ mode: DynamoDisplayMode) {
        self.nameLabelWidth.constant = self.frame.width
        if mode == .Top {
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
}

