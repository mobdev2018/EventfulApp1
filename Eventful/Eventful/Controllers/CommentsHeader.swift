//
//  CommentsHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/28/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class CommentHeader: UICollectionViewCell {
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 10, paddingBottom: 4, paddingRight: 0, width: 50, height: 50)
    }
    
    lazy var backButton: UIButton = {
       let backButton = UIButton(type: .system)
        backButton.setImage(#imageLiteral(resourceName: "icons8-Expand Arrow-48").withRenderingMode(.alwaysOriginal), for: .normal)
        return backButton
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
