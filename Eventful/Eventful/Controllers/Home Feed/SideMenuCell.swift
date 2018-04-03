//
//  SideMenuCell.swift
//  Eventful
//
//  Created by Shawn Miller on 4/2/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit

class SideMenuCell: UICollectionViewCell {
    var sideMenu: SideMenu? {
    didSet{
        nameLabel.text = (sideMenu?.name).map { $0.rawValue }
    }
    }
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont(name: "Avenir-Medium", size: 13.0)
        return nameLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    @objc func setupViews(){
        backgroundColor = .white
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(5)
        }
        let currentUserDividerView = UIView()
        currentUserDividerView.backgroundColor = UIColor.lightGray
        addSubview(currentUserDividerView)
        currentUserDividerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.height.greaterThanOrEqualTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
