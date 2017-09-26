//
//  CommentsSectionController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Foundation

class CommentsSectionController: ListSectionController {
var comment: CommentGrabbed?
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
         dummyCell.comment = comment
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, estimatedSize.height)
        return  CGSize(width: collectionContext!.containerSize.width, height: height)
        
    }
    
    override var minimumLineSpacing: CGFloat {
        get {
            return 0.0
        }
        set {
            self.minimumLineSpacing = 0.0
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CommentCell.self, for: self, at: index) as? CommentCell else {
            fatalError()
        }
        print(comment)
        
        cell.comment = comment
        return cell
    }
    override func didUpdate(to object: Any) {
        comment = object as! CommentGrabbed
    }
    override func didSelectItem(at index: Int){
        
        
    }


}
