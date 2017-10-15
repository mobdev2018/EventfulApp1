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
    
    public var backgroundImageView: UIImageView = {
        let firstImage = UIImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleAspectFill
        return firstImage
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
    
    // MARK: - Action
    
    public func refreshView() {
        if let img = backgroundImageView.image {
            let (complementaryColor, complementaryOpacity) = DynamoUtils.computeComplementaryColor(image: img)
            self.calenderUnit.backgroundColor = complementaryColor
            self.darkOverlayImageView.alpha = complementaryOpacity
        }
    }
    
    // MARK: - Private variables

    private var nameLabel:UILabel!
    private var nameLabelLeading:NSLayoutConstraint!
    private var nameLabelWidth:NSLayoutConstraint!
    private var nameLabelHeight:NSLayoutConstraint!
    private var calenderToNameLabel:NSLayoutConstraint!
    private var calenderUnit:UIView!
    private var overlayTextView:UIView!
    private var calenderUnitBottom:NSLayoutConstraint!
    private var overlayTextViewBottom:NSLayoutConstraint!
    private var dayLabel:UILabel!
    private var monthLabel:UILabel!
    private var darkOverlayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dark_overlay", in: Bundle(for: DynamoCollectionView.self), compatibleWith: nil)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    //private var overlayButton:UIButton!
    
    private func setupViews() {
        self.addSubview(self.backgroundImageView)
        self.backgroundColor = UIColor.white
        
        NSLayoutConstraint.activateViewConstraints(self.backgroundImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
  
        self.calenderUnit = UIView()
        self.calenderUnit.layer.cornerRadius = 5.0
        self.calenderUnit.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.calenderUnit)
        NSLayoutConstraint.activateViewConstraints(self.calenderUnit, inSuperView: self, withLeading: 10.0, trailing: nil, top: nil, bottom: nil, width: 30.0, height: 30.0)
        self.calenderUnitBottom = NSLayoutConstraint.activateBottomConstraint(withView: self.calenderUnit, superView: self, andSeparation: 5.0)
        
        // dark overlay
        self.addSubview(self.darkOverlayImageView)
        NSLayoutConstraint.activateViewConstraints(self.darkOverlayImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
        
        self.overlayTextView = UIView()
        self.overlayTextView.layer.cornerRadius = 5.0
        self.overlayTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.overlayTextView)
        NSLayoutConstraint.activateViewConstraints(self.overlayTextView, inSuperView: self, withLeading: 10.0, trailing: nil, top: nil, bottom: nil, width: 30.0, height: 30.0)
        self.overlayTextViewBottom = NSLayoutConstraint.activateBottomConstraint(withView: self.overlayTextView, superView: self, andSeparation: 5.0)
        
        self.dayLabel = UILabel()
        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dayLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
        self.dayLabel.textColor = .white
        self.dayLabel.textAlignment = .center
        self.overlayTextView.addSubview(self.dayLabel)
        NSLayoutConstraint.activateViewConstraints(self.dayLabel, inSuperView: self.overlayTextView, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: nil, width: nil, height: 20.0)
        
        self.monthLabel = UILabel()
        self.monthLabel.translatesAutoresizingMaskIntoConstraints = false
        self.monthLabel.font = UIFont.systemFont(ofSize: 8.0, weight: UIFont.Weight.light)
        self.monthLabel.textColor = .white
        self.monthLabel.textAlignment = .center
        self.overlayTextView.addSubview(self.monthLabel)
        NSLayoutConstraint.activateViewConstraints(self.monthLabel, inSuperView: self.overlayTextView, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.dayLabel, secondView: self.monthLabel, andSeparation: -5.0)
        _ = NSLayoutConstraint.activateHeightConstraint(view: self.dayLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)
        
        self.nameLabel = UILabel()
        self.nameLabel.numberOfLines = 2
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = UIFont.systemFont(ofSize: 8.0, weight: UIFont.Weight.regular)
        self.nameLabel.textColor = .white
        //self.nameLabel.shadowColor = UIColor.clear
        //self.nameLabel.shadowOffset = CGSize(width: 1, height: -2)
        self.addSubview(self.nameLabel)
        //variable leading
        self.nameLabelLeading = NSLayoutConstraint.activateLeadingConstraint(withView: self.nameLabel, superView: self, andSeparation: 5.0)
        //variable width
        self.nameLabelWidth = NSLayoutConstraint.activateWidthConstraint(view: self.nameLabel, withWidth: min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)/3)
        //variable bottom
        self.calenderToNameLabel = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.calenderUnit, secondView: self.nameLabel, andSeparation: 5.0)
        //variable height
        self.nameLabelHeight = NSLayoutConstraint.activateHeightConstraint(view: self.nameLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delaysTouchesBegan = false
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
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
            self.calenderUnitBottom.constant = -self.frame.height/2.0 + 15.0
            self.overlayTextViewBottom.constant = -self.frame.height/2.0 + 15.0
            self.nameLabelLeading.constant = 10.0
            self.calenderToNameLabel.constant =  3.0
            self.nameLabelHeight.constant = 1.0
        }
        else {
            self.calenderUnitBottom.constant = -17.0
            self.overlayTextViewBottom.constant = -17.0
            self.nameLabelLeading.constant = 10.0
            self.calenderToNameLabel.constant = 3.0
            self.nameLabelHeight.constant = 1.0
        }
    }
}

