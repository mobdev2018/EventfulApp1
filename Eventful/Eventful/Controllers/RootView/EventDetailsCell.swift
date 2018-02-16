//
//  EventDetailCell.swift
//  Eventful
//
//  Created by Shawn Miller on 2/10/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
protocol TransitionDelegate:NSObjectProtocol{
    func eventDetailTransition(currentEvent: Event)
}
class EventDetailsCell: UITableViewCell {
    weak var transitionDelegate:TransitionDelegate?
    var details:Event?{
        didSet{
            if let value = details?.currentEventName.uppercased(){
                labelDesciption.text = value
            }else{
                labelDesciption.text = "Uknown"
            }
            if let value = details?.currentEventDate{
                var dateString = ""
                dateString = "From "+value
                if let startTime = details?.currentEventTime{
                    dateString += ",\(startTime)"
                }
                if let end = details?.currentEventEndDate{
                    dateString += " to \(end)"
                }
                if let endTime = details?.currentEventEndTime{
                    dateString += ",\(endTime)"
                }
                labelDate.text = dateString
            }else{
                labelDate.text = "Uknown"
            }
            
            guard let url = URL(string: (details?.currentEventImage)!) else { return }
            eventImageView.af_setImage(withURL: url)
        }
    }
    
    lazy var eventImageView: CustomImageView = {
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

    @objc func eventDetailTransition(currentEvent: Event){
        print("View events button touched")
        if let delegate = self.transitionDelegate{
            delegate.eventDetailTransition(currentEvent: details!)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(eventImageView)
        let sizeOfImage:CGFloat = 33
        eventImageView.heightAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        eventImageView.layer.cornerRadius = sizeOfImage/2
        eventImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 4.5, paddingLeft: 45, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(labelDesciption)
        addSubview(labelDate)
        labelDesciption.anchor(top: self.topAnchor, left: eventImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        labelDate.anchor(top: labelDesciption.topAnchor, left: eventImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
