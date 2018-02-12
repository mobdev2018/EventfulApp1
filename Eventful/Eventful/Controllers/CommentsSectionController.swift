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
import Firebase

protocol CommentsSectionDelegate: class {
    func CommentSectionUpdared(sectionController: CommentsSectionController)
}
class CommentsSectionController: ListSectionController,ListSupplementaryViewSource, CommentCellDelegate, ReplyToCommentCellDelegate {
    func optionsButtonTapped(cell: ReplyToCommentCell) {
        print("Option Button Tapped")
    }
    
    var currentViewController: NewCommentsViewController!
    
    weak var delegate: CommentsSectionDelegate? = nil
   weak var comment: CommentGrabbed?
    let userProfileController = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())
    var eventKey: String?
    override init() {
        super.init()
        // supplementaryViewSource = self
        //sets the spacing between items in a specfic section controller
        inset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        supplementaryViewSource = self
    }
    
    // MARK: Suplementary Views
    
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            return userHeaderView(atIndex: index)
        default:
            fatalError()
        }
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comment
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, estimatedSize.height)
        return  CGSize(width: collectionContext!.containerSize.width, height: height)
    }
    
    // MARK: Private
    private func userHeaderView(atIndex index: Int) -> UICollectionReusableView {
        guard let view = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, for: self, class: CommentCell.self, at: index) as? CommentCell else {
            fatalError()
        }
        view.comment = comment
        view.delegate = self
        
        return view
    }
    
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        return (comment?.replies.count)!
    }
    override func sizeForItem(at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        var dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comment
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, (estimatedSize.height))
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
        guard let cell = collectionContext?.dequeueReusableCell(of: ReplyToCommentCell.self, for: self, at: index) as? ReplyToCommentCell else {
            fatalError()
        }
        cell.comment = comment?.replies[index]
        cell.delegate = self
        return cell
    }
    override func didUpdate(to object: Any) {
        comment = object as? CommentGrabbed
    }
    override func didSelectItem(at index: Int){
    }
    
    func optionsButtonTapped(cell: CommentCell){
        print("like")
   
        let comment = self.comment
        _ = comment?.uid
        
        // 3
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 4
        if comment?.uid != User.current.uid {
            let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) {[weak self] _ in
                ChatService.flag(comment!)
                
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self?.viewController?.present(okAlert, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let replyAction = UIAlertAction(title: "Reply to Comment", style: .default, handler: { [weak self](_) in
                //do something here later to facilitate reply comment functionality

                print("Attempting to reply to user \(String(describing: comment?.user?.username)) comment")
                self?.currentViewController.containerView.commentTextView.hidePlaceholderLabel()
                self?.currentViewController.containerView.commentTextView.text = "@" + (comment?.user?.username)! + " "
                self?.currentViewController.containerView.commentTextView.becomeFirstResponder()
                self?.currentViewController.isReplying = true
                self?.currentViewController.commentID = (comment?.commentID)!
                self?.currentViewController.notificationData = Notifications.init(eventKey: (comment?.eventKey)!, repliedTo: (comment?.uid)!, repliedBy: User.current.uid, content: User.current.username! + " has replied to your comment", commentId: (comment?.commentID)!, profilePic: (User.current.profilePic)!, type: "comment")
            })
            alertController.addAction(replyAction)
            alertController.addAction(cancelAction)
            alertController.addAction(flagAction)
        }else{
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete Comment", style: .default, handler: {[weak self] _ in
                ChatService.deleteComment(comment!, (comment?.eventKey)!)
                let okAlert = UIAlertController(title: nil, message: "Comment Has Been Deleted", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self?.viewController?.present(okAlert, animated: true, completion: nil)
                self?.onItemDeleted()

            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
        }
        self.viewController?.present(alertController, animated: true, completion: nil)
        
    }
    func onItemDeleted() {
        delegate?.CommentSectionUpdared(sectionController: self)
    }
    func handleProfileTransition(tapGesture: UITapGestureRecognizer){
        userProfileController.user = comment?.user
        if Auth.auth().currentUser?.uid != comment?.uid{
                    self.viewController?.present(userProfileController, animated: true, completion: nil)
        }else{
            //do nothing
            
        }

    }

    deinit {
        print("CommentSectionController class removed from memory")
    }
}
