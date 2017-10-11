//
//  EventDetailViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/7/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EventDetailViewController: UIViewController {
    
    var currentEvent : Event?{
        didSet{
            let imageURL = URL(string: (currentEvent?.currentEventImage)!)
            currentEventImage.af_setImage(withURL: imageURL!)
            currentEventTime.text = currentEvent?.currentEventTime
            currentEventDate.text = currentEvent?.currentEventDate
            eventNameLabel.text = currentEvent?.currentEventName.capitalized
            let firstPartOfAddress = (currentEvent?.currentEventStreetAddress)!  + "\n" + (currentEvent?.currentEventCity)! + ", " + (currentEvent?.currentEventState)!
            let secondPartOfAddress = firstPartOfAddress + " " + String(describing: currentEvent?.currentEventZip)
            addressLabel.text = secondPartOfAddress
            descriptionLabel.text = currentEvent?.currentEventDescription
            descriptionLabel.font = UIFont(name: (descriptionLabel.font?.fontName)!, size: 12)
            navigationItem.title = currentEvent?.currentEventName.capitalized
        }
    }
    var stackView: UIStackView?
    var userInteractStackView: UIStackView?
    //    var users = [User]()
    let camera = CameraViewController()
    let commentsController = CommentsViewController(collectionViewLayout: UICollectionViewFlowLayout())
    let eventStory = StoriesViewController()
    let newCommentsController = NewCommentsViewController()
    
    
    //variables that will hold data sent in through previous event controller
    
    var eventKey = ""
    var eventPromo = ""
 
    
    var currentEventAttendCount = 0
    //
    lazy var currentEventImage : UIImageView = {
        let currentEvent = UIImageView()
        //let imageURL = URL(string: self.eventImage)
        // currentEvent.af_setImage(withURL: imageURL!)
        currentEvent.clipsToBounds = true
        currentEvent.translatesAutoresizingMaskIntoConstraints = false
        currentEvent.contentMode = .scaleAspectFit
        currentEvent.isUserInteractionEnabled = true
        currentEvent.layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePromoVid))
        currentEvent.isUserInteractionEnabled = true
        currentEvent.addGestureRecognizer(tapGestureRecognizer)
        return currentEvent
    }()
    
    
    
    
    fileprivate func extractedFunc(_ url: URL?) -> VideoViewController {
        return VideoViewController(videoURL: url!)
    }
    
    @objc func handlePromoVid(){
        print("Image tappped")
        print(eventPromo)
        let url = URL(string: eventPromo)
        let videoLauncher = extractedFunc(url)
        videoLauncher.nextButton.isHidden = true
        present(videoLauncher, animated: true, completion: nil)
        
        //        self.navigationController?.pushViewController(videoLauncher, animated: true)
        
    }
    
    lazy var currentEventTime: UILabel = {
        let currentEventTime = UILabel()
        //        currentEventTime.text = self.eventTime
        currentEventTime.font = UIFont(name: currentEventTime.font.fontName, size: 12)
        return currentEventTime
    }()
    
    
    lazy var currentEventDate: UILabel = {
        let currentEventDate = UILabel()
        //        currentEventDate.text = self.eventDate
        currentEventDate.font = UIFont(name: currentEventDate.font.fontName, size: 12)
        return currentEventDate
    }()
    
    
    //will show the event name
    lazy var eventNameLabel: UILabel = {
        let currentEventName = UILabel()
        //        currentEventName.text = self.eventName.capitalized
        currentEventName.translatesAutoresizingMaskIntoConstraints = false
        return currentEventName
    }()
    //wil be responsible for creating the address  label
    lazy var addressLabel : UILabel = {
        let currentAddressLabel = UILabel()
        currentAddressLabel.numberOfLines = 0
        currentAddressLabel.textColor = UIColor.lightGray
        currentAddressLabel.font = UIFont(name: currentAddressLabel.font.fontName, size: 12)
        return currentAddressLabel
    }()
    //wil be responsible for creating the description label
    lazy var descriptionLabel : UITextView = {
        let currentDescriptionLabel = UITextView()
        currentDescriptionLabel.isEditable = false
        currentDescriptionLabel.textContainer.maximumNumberOfLines = 0
        currentDescriptionLabel.textColor = UIColor.black
        currentDescriptionLabel.textAlignment = .justified
        return currentDescriptionLabel
    }()
    
    lazy var commentsViewButton : UIButton = {
        let viewComments = UIButton(type: .system)
        viewComments.setImage(#imageLiteral(resourceName: "commentBubble").withRenderingMode(.alwaysOriginal), for: .normal)
        viewComments.setTitleColor(.white, for: .normal)
        viewComments.addTarget(self, action: #selector(presentComments), for: .touchUpInside)
        return viewComments
    }()
    
    
    @objc func presentComments(){
        print("Comments button pressed")
        commentsController.eventKey = eventKey
        newCommentsController.eventKey = eventKey
        present(commentsController, animated: true, completion: nil)
        
    }
    
    
    lazy var attendingButton: UIButton = {
        let attendButton = UIButton(type: .system)
        attendButton.setImage(#imageLiteral(resourceName: "walkingNotFilled").withRenderingMode(.alwaysOriginal), for: .normal)
        attendButton.addTarget(self, action: #selector(handleAttend), for: .touchUpInside)
        return attendButton
    }()
    
    lazy var attendCount : UILabel = {
        let currentAttendCount = UILabel()
        currentAttendCount.textColor = UIColor.black
        var numberAttending = 0
        //numberAttending = AttendService.fethAttendCount(for: self.eventKey)
        let ref = Database.database().reference().child("Attending").child(self.eventKey)
        
        ref.observe(.value, with: { (snapshot: DataSnapshot!) in
            numberAttending += Int(snapshot.childrenCount)
            currentAttendCount.text  = String(numberAttending)
            
        })
        
        return currentAttendCount
    }()
    
    lazy var commentCount : UILabel = {
        let currentCommentCount = UILabel()
        currentCommentCount.textColor = UIColor.black
        //numberAttending = AttendService.fethAttendCount(for: self.eventKey)
        return currentCommentCount
    }()
    
    
    @objc func handleAttend(){
        print("Handling attend from within cell")
        // 2
        attendingButton.isUserInteractionEnabled = false
        // 3
        AttendService.setIsAttending(!((currentEvent?.isAttending)!), from: currentEvent) { (success) in
            // 5
            
            defer {
                self.attendingButton.isUserInteractionEnabled = true
            }
            
            // 6
            guard success else { return }
            
            // 7
            self.currentEvent?.isAttending = !((self.currentEvent!.isAttending))
            self.currentEvent?.currentAttendCount += !((self.currentEvent!.isAttending)) ? 1 : -1
            
        }
        
    }
    
    //will add the button to add a video or picture to the story
    lazy var addToStoryButton : UIButton =  {
        let addToStory = UIButton(type: .system)
        addToStory.setImage(#imageLiteral(resourceName: "icons8-Plus-64").withRenderingMode(.alwaysOriginal), for: .normal)
        addToStory.addTarget(self, action: #selector(beginAddToStory), for: .touchUpInside)
        return addToStory
    }()
    
    @objc func beginAddToStory(){
        print("Attempting to load camera")
        camera.eventKey = self.eventKey
        present(camera, animated: true, completion: nil)
        
        //        self.navigationController?.pushViewController(camera, animated: true)
    }
    
    lazy var viewStoryButton : UIView = {
        let viewStoryButton = UIView()
        viewStoryButton.backgroundColor = UIColor.red
        viewStoryButton.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewStory))
        viewStoryButton.addGestureRecognizer(tapGesture)
        return viewStoryButton
    }()
    
    @objc func handleViewStory(){
        print("Attempting to view story")
        eventStory.eventKey = self.eventKey
        present(eventStory, animated: true, completion: nil)
    }
    
    

    
    @objc func swipeAction(_ swipe: UIGestureRecognizer){
        if let swipeGesture = swipe as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                break
            case UISwipeGestureRecognizerDirection.down:
                dismiss(animated: true, completion: nil)
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                break
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                break
            default:
                break
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        view.backgroundColor = UIColor.white
//        self.navigationItem.hidesBackButton = true
//        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
//        self.navigationItem.leftBarButtonItem = backButton
        
        //Subviews will be added here
        view.addSubview(currentEventImage)
        view.addSubview(currentEventDate)
        
        //        view.addSubview(attendCount)
        //        view.addSubview(commentCount)
        
        //Constraints will be added here
        _ = currentEventImage.anchor(top: view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: -305, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.view.frame.width, height: 200)
        _ = currentEventDate.anchor(top: currentEventImage.bottomAnchor, left: userInteractStackView?.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 90, height: 50)
        //          _ = attendCount.anchor(top: attendingButton.bottomAnchor, left: commentCount.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 60, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        //        _ = commentCount.anchor(top: commentsViewButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        //        _ = addToStoryButton.anchor(top: stackView?.bottomAnchor, left: attendingButton.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 40, height: 30)
        //        _ = viewStoryButton.anchor(top: stackView?.bottomAnchor, left: addToStoryButton.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        //        viewStoryButton.layer.cornerRadius = 40/2
        attendingButton.isSelected = (currentEvent?.isAttending)!
        setupEventDisplayScreen()
        userInteractionView()
        
        // navigationController?.isHeroEnabled = true
    }
    
    fileprivate func setupEventDisplayScreen(){
        stackView = UIStackView(arrangedSubviews: [ eventNameLabel,addressLabel,descriptionLabel])
        view.addSubview(stackView!)
        stackView?.distribution = .fill
        stackView?.axis = .vertical
        stackView?.spacing = 5.0
        stackView?.anchor(top: currentEventImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 250)
    }
    
    fileprivate func userInteractionView(){
        userInteractStackView = UIStackView(arrangedSubviews: [commentsViewButton, attendingButton, addToStoryButton, viewStoryButton])
        viewStoryButton.heightAnchor.constraint(equalToConstant: 50)
        viewStoryButton.widthAnchor.constraint(equalToConstant: 50)
        viewStoryButton.layer.cornerRadius = 150/2
        view.addSubview(userInteractStackView!)
        userInteractStackView?.distribution = .fillEqually
        userInteractStackView?.axis = .horizontal
        userInteractStackView?.spacing = 10.0
        userInteractStackView?.anchor(top: stackView?.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
        let ref = Database.database().reference().child("Comments").child(self.eventKey)
        
        ref.observe(.value, with: { (snapshot: DataSnapshot!) in
            var numberOfComments = 0
            numberOfComments = numberOfComments + Int(snapshot.childrenCount)
            self.commentCount.text  = String(numberOfComments)
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
