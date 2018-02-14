//
//  EventCollectionCell.swift
//  Eventful
//
//  Created by Shawn Miller on 2/10/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int)
}
class CollapsibleTableViewHeader:UITableViewHeaderFooterView {
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    let arrowLabel: UILabel = {
        let arrowLabel = UILabel()
        arrowLabel.textColor = .black
        return arrowLabel
    }()
    var friendDetails: Friend?{
        didSet{
            var name = "N/A"
            var total = 0
            if let value = friendDetails?.friendName{
                name = value
            }
            if let value = friendDetails?.events.count{
                total = value
            }
            if let value = friendDetails?.imageUrl{
                profileImageView.loadImage(urlString: value)
            }else{
                profileImageView.image = #imageLiteral(resourceName: "icons8-User Filled-50")
            }
            
            setLabel(name: name, totalEvents: total)

        }
    }
    
    let container:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.3
        return view
    }()
    //profile image view for the user
    var profileImageView:CustomImageView={
        let iv = CustomImageView()
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.layer.borderWidth = 0.3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    //will show the name of the user as well as the total number of events he is attending
    let labelNameAndTotalEvents:UILabel={
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setUpCell()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(_:))))
//        contentView.addSubview(arrowLabel)
    }
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setUpCell(){
        print("Attempting to setup cell")
        addSubview(container)
        container.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        container.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        container.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        container.addSubview(profileImageView)
        container.addSubview(labelNameAndTotalEvents)
        container.addSubview(arrowLabel)

        let sizeOfImage:CGFloat = 40
        profileImageView.heightAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        profileImageView.layer.cornerRadius = sizeOfImage/2
        profileImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 5).isActive = true
        
        labelNameAndTotalEvents.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 0).isActive = true
        labelNameAndTotalEvents.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        labelNameAndTotalEvents.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -5).isActive = true
        labelNameAndTotalEvents.heightAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
        
        arrowLabel.textColor = UIColor.white
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
        arrowLabel.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        arrowLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        arrowLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
    }
    
    func setLabel(name:String,totalEvents:Int){
        let mainString = NSMutableAttributedString()
        
        let attString = NSAttributedString(string:name+"\n" , attributes: [NSAttributedStringKey.foregroundColor:UIColor.black,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14)])
        mainString.append(attString)
        
        let attString2 = NSAttributedString(string:totalEvents == 0 ? "No events" : "\(totalEvents) \(totalEvents == 1 ? "Event" : "Events")" , attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkGray,NSAttributedStringKey.font:UIFont.italicSystemFont(ofSize: 12)])
        mainString.append(attString2)
        labelNameAndTotalEvents.attributedText = mainString
        
    }
    
    func setCollapsed(_ collapsed: Bool) {
        // Animate the arrow rotation (see Extensions.swf)
        print(collapsed)
        //0.0
        arrowLabel.rotate(collapsed ? .pi / 2: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}







