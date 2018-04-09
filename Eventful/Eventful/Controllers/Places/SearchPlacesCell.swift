//
//  SearchPlacesCell.swift
//  Eventful
//
//  Created by Shawn Miller on 4/6/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit

class SearchPlacesCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    var dividerView: UIView?

    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"Avenir", size: 16.5)
        return sectionNameLabel
    }()
    @objc func setupViews(){
        backgroundColor = .clear
        addSubview(sectionNameLabel)
        sectionNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).inset(15)
            make.left.equalTo(self.snp.left).offset(10)
        }
        
           dividerView = UIView()
        dividerView?.backgroundColor = UIColor.lightGray
        addSubview(dividerView!)
        dividerView?.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
