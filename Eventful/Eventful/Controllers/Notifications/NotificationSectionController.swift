//
//  NotificationSectionController.swift
//  Eventful
//
//  Created by Shawn Miller on 2/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//
import Foundation
import IGListKit
import Firebase
protocol NotificationsSectionDelegate: class {
    func NotificationsSectionUpdared(sectionController: NotificationsSectionController)
}
class NotificationsSectionController: ListSectionController {
    weak var delegate: NotificationsSectionDelegate? = nil
    weak var notif: Notifications?
    
    override init() {
        super.init()
        // supplementaryViewSource = self
        //sets the spacing between items in a specfic section controller
        inset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        let dummyCell = NotificationCell(frame: frame)
        dummyCell.notification = notif
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, (estimatedSize.height))
        return  CGSize(width: collectionContext!.containerSize.width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: NotificationCell.self, for: self, at: index) as? NotificationCell else {
            fatalError()
        }
        //  print(comment)
        cell.notification = notif
        //cell.delegate = self
        return cell
    }
    
    override func didUpdate(to object: Any) {
        notif = object as? Notifications
    }
    
    func NotificationsSectionUpdared(sectionController: NotificationsSectionController){
        print("Tried to update")
        delegate?.NotificationsSectionUpdared(sectionController: self)
    }
    
    override var minimumLineSpacing: CGFloat {
        get {
            return 0.0
        }
        set {
            self.minimumLineSpacing = 0.0
        }
    }
    
    deinit {
        print("NotifSectionController class removed from memory")
    }
    
}
