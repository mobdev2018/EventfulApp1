//
//  EventDetailCell.swift
//  Eventful
//
//  Created by Shawn Miller on 2/10/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class EventDetailsCell:UICollectionViewCell{
    
    var details:EventDetails?{
        didSet{
            if let value = details?.name?.uppercased(){
                labelDesciption.text = value
            }else{
                labelDesciption.text = "Uknown"
            }
            if let value = details?.startDate{
                var dateString = ""
                dateString = "From "+value
                if let startTime = details?.startTime{
                    dateString += ",\(startTime)"
                }
                if let end = details?.endDate{
                    dateString += " to \(end)"
                }
                if let endTime = details?.endTime{
                    dateString += ",\(endTime)"
                }
                labelDate.text = dateString
            }else{
                labelDate.text = "Uknown"
            }
            
            guard let url = URL(string: (details?.imageURL)!) else { return }
            imageView.af_setImage(withURL: url)
        }
    }
    
    lazy var imageView: CustomImageView = {
        let eventImageView = CustomImageView()
        eventImageView.layer.masksToBounds = true
        eventImageView.layer.borderColor = UIColor.lightGray.cgColor
        eventImageView.layer.borderWidth = 0.3
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(eventDetailTransition))
        eventImageView.isUserInteractionEnabled = true
        eventImageView.addGestureRecognizer(tapGestureRecognizer)
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        return eventImageView
    }()
    
    @objc func eventDetailTransition (){
        print("cell tapped")
    }
    
    let labelDesciption:UILabel={
        let label = UILabel()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    let labelDate:UILabel={
        let label = UILabel()
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let seperator1:UIView={
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(seperator1)
        addConstraintsWithFormatt("H:|[v0]|", views: seperator1)
        addConstraintsWithFormatt("V:[v0(0.35)]|", views: seperator1)
        addSubview(imageView)
        let sizeOfImage:CGFloat = 33
        imageView.heightAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        imageView.layer.cornerRadius = sizeOfImage/2
        imageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 4.5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(labelDesciption)
        addSubview(labelDate)
        labelDesciption.anchor(top: self.topAnchor, left: imageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        labelDate.anchor(top: labelDesciption.topAnchor, left: imageView.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
