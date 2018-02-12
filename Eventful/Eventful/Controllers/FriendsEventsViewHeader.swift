//
//  FriendsEventsViewHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 2/10/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Foundation
class FriendsEventsViewHeader: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(viewEventsButton)
        viewEventsButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 3.5, paddingLeft: 3.5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    lazy var viewEventsButton: UIButton = {
        let viewEventsButton = UIButton(type: .system)
        viewEventsButton.setTitle( "View Events For This User", for: .normal)
        viewEventsButton.setTitleColor(.black, for: .normal)
        //viewEventsButton.addTarget(self, action: #selector(viewEventsButtonTapped), for: .touchUpInside)
        return viewEventsButton
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
