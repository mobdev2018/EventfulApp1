//
//  NewCommentsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Firebase


class NewCommentsViewController: UIViewController, UITextFieldDelegate,CommentsSectionDelegate,CommentInputAccessoryViewDelegate {
    //array of comments which will be loaded by a service function
    var comments = [CommentGrabbed]()
    var messagesRef: DatabaseReference?
    var isReplying = false
    var commentID = ""
    var notificationData : Notifications!
    var showUsersList = false
    
    var bottomConstraint: NSLayoutConstraint?
    public let addHeader = "addHeader" as ListDiffable
    public var eventKey = ""
    
    var keyboardHeight : CGFloat = 0
    
    var selectUserIdentifier = "selectUserIdentifier"
    
    //This creates a lazily-initialized variable for the IGListAdapter. The initializer requires three parameters:
    //1 updater is an object conforming to IGListUpdatingDelegate, which handles row and section updates. IGListAdapterUpdater is a default implementation that is suitable for your usage.
    //2 viewController is a UIViewController that houses the adapter. This view controller is later used for navigating to other view controllers.
    //3 workingRangeSize is the size of the working range, which allows you to prepare content for sections just outside of the visible frame.
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    
    // 1 IGListKit uses IGListCollectionView, which is a subclass of UICollectionView, which patches some functionality and prevents others.
    let collectionView: UICollectionView = {
        // 2 This starts with a zero-sized rect since the view isn’t created yet. It uses the UICollectionViewFlowLayout just as the ClassicFeedViewController did.
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        // 3 The background color is set to white
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.frame = CGRect.zero
        view.isHidden = true
        return view
    }()
    
    //will fetch the comments from the database and append them to an array
    fileprivate func fetchComments(){
        comments.removeAll()
        messagesRef = Database.database().reference().child("Comments").child(eventKey)
       // print(eventKey)
        // print(comments.count)
        let query = messagesRef?.queryOrderedByKey()
        query?.observe(.value, with: { (snapshot) in
            self.comments.removeAll()
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            allObjects.forEach({ (snapshot) in
                guard let commentDictionary = snapshot.value as? [String: Any] else{
                    return
                }
                guard let uid = commentDictionary["uid"] as? String else{
                    return
                }
/*<<<<<<< Updated upstream
                UserService.show(forUID: uid, completion: { [weak self](user) in
                    if let user = user {
                        let commentFetched = CommentGrabbed(user: user, dictionary: commentDictionary)
                        commentFetched.commentID = snapshot.key
                        let filteredArr = self?.comments.filter { (comment) -> Bool in
                            return comment.commentID == commentFetched.commentID
                        }
                        if filteredArr?.count == 0 {
                            self?.comments.append(commentFetched)
=======*/
                
                var userReplies = [ReplyToComment]()
                
                let commentUser = Users.sharedInstance.allUsers.object(forKey: uid)
                
                let replies = commentDictionary["replies"] as? [String: Any]
                // Checking if there are any replies to any comment
                // Looping throught the replies and binded it in model with comment
                if (replies != nil){
                    for reply in replies!{
                        let dict = reply.value as! [String: Any]
                        let user = Users.sharedInstance.allUsers.object(forKey: dict["uid"] as! String)
                        let userReply = ReplyToComment(dictionary: dict, user: user as! User)
                        userReply.replyId = reply.key
                        userReplies.append(userReply)
                    }
                    // Sorting replies of the comment
                    let sortedReplies = self.sortReplies(repliesArray: userReplies)
                    
                    let commentFetched = CommentGrabbed(user: commentUser as! User, dictionary: commentDictionary, replies: sortedReplies)
                    commentFetched.commentID = snapshot.key
                    self.comments.append(commentFetched)
                    self.sortComments(commentFetched: commentFetched)
                }else{
                    let commentFetched = CommentGrabbed(user: commentUser as! User, dictionary: commentDictionary, replies: userReplies)
                    commentFetched.commentID = snapshot.key
                    self.comments.append(commentFetched)
                    self.sortComments(commentFetched: commentFetched)
                }
                
//                self.adapter.performUpdates(animated: true)
                
               /* UserService.show(forUID: uid, completion: { (user) in
                    if let user = user {
                        var userReplies = [ReplyToComment]()

                        let replies = commentDictionary["replies"] as? [String: Any]
                        
                        if (replies != nil){
                            
                            let countOfObjs : Int = (replies?.count)!
                            
                            var currentCount : Int = 0
>>>>>>> Stashed changes
                            
                            for  obj in replies!{
                                
                                let dict = obj.value as! [String: Any]
                                
                                UserService.show(forUID: dict["uid"] as! String, completion: { (otherUser) in
                                    if let otherUser = otherUser{
                                        let replies = ReplyToComment(dictionary: dict, user: otherUser)
                                        replies.replyId = obj.key
                                        userReplies.append(replies)
                                        
                                        currentCount = currentCount + 1
                                        
                                        if (countOfObjs == currentCount){
                                            
                                            let sortedReplies = self.sortReplies(repliesArray: userReplies)
                                            
                                           let commentFetched = CommentGrabbed(user: user, dictionary: commentDictionary, replies: sortedReplies)
                                            commentFetched.commentID = snapshot.key
                                            self.comments.append(commentFetched)
                                            self.adapter.performUpdates(animated: true)
//                                            self.adapter.reloadData(completion: nil)
                                           self.sortComments(commentFetched: commentFetched)
                                        }
                                    }
                                })
                            }
                            
                        }else{
                            let commentFetched = CommentGrabbed(user: user, dictionary: commentDictionary, replies: userReplies)
                            commentFetched.commentID = snapshot.key
                            self.comments.append(commentFetched)
                            self.adapter.performUpdates(animated: true)
//                            self.adapter.reloadData(completion: nil)
                            self.sortComments(commentFetched: commentFetched)
                        }
<<<<<<< Updated upstream
                        self?.adapter.performUpdates(animated: true)
=======
>>>>>>> Stashed changes
                    }else{
                        print("user is null")
                        
                    }
<<<<<<< Updated upstream
                    self?.comments.sort(by: { (comment1, comment2) -> Bool in
                        return comment1.creationDate.compare(comment2.creationDate) == .orderedAscending
                    })
                    self?.comments.forEach({ (comments) in
                    })
                })
=======
                })*/
                
            })
            print(self.comments)
            self.adapter.performUpdates(animated: true)
        }, withCancel: { (error) in
            print("Failed to observe comments")
        })
        
        
        //first lets fetch comments for current event
    }
    
    fileprivate func sortComments(commentFetched: CommentGrabbed){
        let filteredArr = self.comments.filter { (comment) -> Bool in
            return comment.commentID == commentFetched.commentID
        }
        if filteredArr.count == 0 {
            self.comments.append(commentFetched)
        }
        self.comments.sort(by: { (comment1, comment2) -> Bool in
            return comment1.creationDate.compare(comment2.creationDate) == .orderedAscending
        })
        self.comments.forEach({ (comments) in
        })
    }
    
    fileprivate func sortReplies(repliesArray: [ReplyToComment]) -> [ReplyToComment]{
        var tempReplyArray = repliesArray
        tempReplyArray.sort(by: { (reply1, reply2) -> Bool in
            return reply1.timeStamp.compare(reply2.timeStamp) == .orderedAscending
        })
        return tempReplyArray
    }
    
    //allows you to gain access to the input accessory view that each view controller has for inputting text
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame:frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()

    // Delegate is fired up when @ sign or space is detected
    @objc func changeList(change: Bool) {
        if (change){
            // When @ sign is detected and table view being shown up with users list
            self.showUsersList = true
            self.tableView.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - keyboardHeight - 50)
            // Hidding main comment list and showing users list
            self.collectionView.isHidden = true
            self.tableView.isHidden = false
        }else{
            // When space occured or user selects any user to mention in comment
            // Hidding main users list and showing comments list
            self.tableView.isHidden = true
            self.collectionView.isHidden = false
            self.showUsersList = false
        }
    }
    
    // reloads table view whenever there is change in users list
    @objc func reloadUsersList() {
        self.tableView.reloadData()
    }

    @objc func handleSubmit(for comment: String?){
        guard let comment = comment, comment.count > 0 else{
            return
        }
        
        let userText = Comments(content: comment, uid: User.current.uid, profilePic: User.current.profilePic!,eventKey: eventKey)
        sendMessage(userText)
        // will clear the comment text field
        self.containerView.clearCommentTextField()
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userinfo = notification.userInfo {
            
            if let keyboardFrame = (userinfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                self.bottomConstraint?.constant = -(keyboardFrame.height)
                
                keyboardHeight = keyboardFrame.height
                
                let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
                
                self.bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame.height) : 0
                if isKeyboardShowing{
                    let contentInset = UIEdgeInsetsMake(0, 0, (keyboardFrame.height), 0)
                    collectionView.contentInset = UIEdgeInsetsMake(0, 0, (keyboardFrame.height), 0)
                    collectionView.scrollIndicatorInsets = contentInset
                }else {
                    let contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    collectionView.scrollIndicatorInsets = contentInset
                }
                
    
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (completion) in
                    if self.comments.count > 0  && isKeyboardShowing {
                        let item = self.collectionView.numberOfItems(inSection: self.collectionView.numberOfSections - 1)-1
                        let lastItemIndex = IndexPath(item: item, section: self.collectionView.numberOfSections - 1)
                        self.collectionView.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: true)
                    }
                })
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-40)
        
        view.addSubview(collectionView)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        collectionView.alwaysBounceVertical = true
        adapter.collectionView = collectionView
        adapter.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: "CommentCell")
//        collectionView.register(CommentHeader.self, forCellWithReuseIdentifier: "HeaderCell")
        collectionView.register(ReplyToCommentCell.self, forCellWithReuseIdentifier: "ReplyToCommentCell")
        tableView.register(SelectUserCell.self, forCellReuseIdentifier: selectUserIdentifier)

        collectionView.keyboardDismissMode = .onDrag
        navigationItem.title = "Comments"
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func GoBack(){
        print("BACK TAPPED")
        self.dismiss(animated: true, completion: nil)
    }
    
    //look here
    func CommentSectionUpdared(sectionController: CommentsSectionController){
//        print("like")
        self.fetchComments()
        self.adapter.performUpdates(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchComments()
        tabBarController?.tabBar.isHidden = true
        //submitButton.isUserInteractionEnabled = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.view.removeFromSuperview()
    }

    //viewDidLayoutSubviews() is overridden, setting the collectionView frame to match the view bounds.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //    collectionView.frame = view.bounds
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        print("NewCommentsController class removed from memory")
        
    }
    
}

extension NewCommentsViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.containerView.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: selectUserIdentifier) as! SelectUserCell
        
        cell.textLabel?.text = self.containerView.searchResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var array = self.containerView.commentTextView.text.components(separatedBy: "@")
        array[array.count - 1] = self.containerView.searchResults[indexPath.row]
        self.containerView.commentTextView.text = array.joined(separator: "@") + " "
        self.changeList(change: false)
    }
}

extension NewCommentsViewController: ListAdapterDataSource {
    // 1 objects(for:) returns an array of data objects that should show up in the collection view. loader.entries is provided here as it contains the journal entries.
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let items:[ListDiffable] = comments
        //print("comments = \(comments)")
        return items
    }
    
    // 2 For each data object, listAdapter(_:sectionControllerFor:) must return a new instance of a section controller. For now you’re returning a plain IGListSectionController to appease the compiler — in a moment, you’ll modify this to return a custom journal section controller.
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        //the comment section controller will be placed here but we don't have it yet so this will be a placeholder
//        if let object = object as? ListDiffable, object === addHeader {
//            return CommentsHeaderSectionController()
//        }
        let sectionController = CommentsSectionController()
        
        sectionController.delegate = self
        sectionController.currentViewController = self
        return sectionController
    }
    
    // 3 emptyView(for:) returns a view that should be displayed when the list is empty. NASA is in a bit of a time crunch, so they didn’t budget for this feature.
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }
}

extension NewCommentsViewController {
    func sendMessage(_ message: Comments) {
        if isReplying {
            // reply to comment
            ChatService.sendReplyToMessage(message, eventKey: eventKey, commentId: self.commentID)
            // sends a notification to user whom user have replied
            ChatService.sendNotification(self.notificationData)
            isReplying = false
            return
        }
        ChatService.sendMessage(message, eventKey: eventKey)
    }
}



