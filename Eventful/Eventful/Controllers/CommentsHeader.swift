//
//  CommentsHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/28/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit


protocol CommentHeaderDelegate: class {
    func commentHeaderTapped(cell: CommentHeader)
}
class CommentHeader: UICollectionViewCell {
    weak var delegate: CommentHeaderDelegate? = nil

    let handleLabel: UILabel = {
        let handleLabel = UILabel()
        handleLabel.textAlignment = NSTextAlignment.center
        return handleLabel
    }()
    var handle: String? {
        get {
            return handleLabel.text
        }
        set {
            handleLabel.text = newValue
        }
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(backButton)
        addSubview(handleLabel)
        handleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: 0, width: 0, height: 40)
        backButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 10, paddingBottom: 4, paddingRight: 0, width: 50, height: 50)
    }
    
    lazy var backButton: UIButton = {
        let backButton = UIButton(type: .system)
        backButton.setImage(#imageLiteral(resourceName: "icons8-Expand Arrow-48").withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addTarget(self, action: #selector(onDismissTapped), for: .touchUpInside)
        return backButton
    }()
    
    @objc func onDismissTapped() {
        delegate?.commentHeaderTapped(cell: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
