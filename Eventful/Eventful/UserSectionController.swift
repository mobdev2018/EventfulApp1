//
//  UserSectionController.swift
//  Eventful
//
//  Created by Dad's Gift on 07/02/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import IGListKit

class UserSectionController: ListSectionController {
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
        return  CGSize(width: collectionContext!.containerSize.width, height: estimatedSize.height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: NotificationCell.self, for: self, at: index) as? NotificationCell else {
            fatalError()
        }
        return cell
    }
}
