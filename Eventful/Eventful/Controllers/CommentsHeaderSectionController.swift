//
//  CommentsHeaderSectionController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/26/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import IGListKit

class CommentsHeaderSectionController: ListSectionController, CommentHeaderDelegate {
    override init(){
        super.init()
    }
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        let dummyCell = CommentHeader(frame: frame)
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, estimatedSize.height)
        return  CGSize(width: collectionContext!.containerSize.width, height: height)
        
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CommentHeader.self, for: self, at: index) as? CommentHeader else {
            fatalError()
        }
        cell.delegate = self
        cell.handle = "Comments"
        return cell
    }
    
    func commentHeaderTapped(cell: CommentHeader){
        print("like")
        viewController?.dismiss(animated: true, completion: nil)
    }

    override func didUpdate(to object: Any) {
        
    }
    override func didSelectItem(at index: Int){
    }
}
