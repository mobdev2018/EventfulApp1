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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let eventDate = dateFormatter.date(from: (currentEvent?.currentEventDate)!)
            dateFormatter.dateFormat = "MMM dd, yyyy"
            currentEventDateTime.text = String(format:"%@ %@", dateFormatter.string(from: eventDate!), (currentEvent?.currentEventTime)!)
//            currentEventTime.text = currentEvent?.currentEventTime
//            currentEventDate.text = currentEvent?.currentEventDate
            eventNameLabel.text = currentEvent?.currentEventName.capitalized
            var address = (currentEvent?.currentEventStreetAddress)!  + "\n" + (currentEvent?.currentEventCity)! + ", " + (currentEvent?.currentEventState)!
            if let zip = currentEvent?.currentEventZip {
                address = String(format:"%@ %ld", address, zip)
            }
//            let secondPartOfAddress = firstPartOfAddress + " " + String(describing: currentEvent?.currentEventZip)
            addressLabel.text = address
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
        currentEvent.layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePromoVid))
        currentEvent.isUserInteractionEnabled = true
        currentEvent.addGestureRecognizer(tapGestureRecognizer)
        return currentEvent
    }()
    
    
    
    
    func handlePromoVid(){
        print("Image tappped")
        let url = URL(string: eventPromo)
        let videoLauncher = VideoViewController(videoURL: url!)
        videoLauncher.nextButton.isHidden = true
        present(videoLauncher, animated: true, completion: nil)
        
        //        self.navigationController?.pushViewController(videoLauncher, animated: true)
        
    }
    
//    lazy var currentEventTime: UILabel = {
//        let currentEventTime = UILabel()
//        currentEventTime.translatesAutoresizingMaskIntoConstraints = false
//
//        //        currentEventTime.text = self.eventTime
//        currentEventTime.font = UIFont(name: currentEventTime.font.fontName, size: 12)
//        return currentEventTime
//    }()
//
//
//    lazy var currentEventDate: UILabel = {
//        let currentEventDate = UILabel()
//        currentEventDate.translatesAutoresizingMaskIntoConstraints = false
//
//        //        currentEventDate.text = self.eventDate
//        currentEventDate.font = UIFont(name: currentEventDate.font.fontName, size: 12)
//        return currentEventDate
//    }()
    
    lazy var currentEventDateTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: label.font.fontName, size: 12)
        return label
    }()
    
    
    //will show the event name
    lazy var eventNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        //        currentEventName.text = self.eventName.capitalized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //wil be responsible for creating the address  label
    lazy var addressLabel : UILabel = {
        let currentAddressLabel = UILabel()
        currentAddressLabel.numberOfLines = 0
        currentAddressLabel.textColor = UIColor.black
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
        currentDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return currentDescriptionLabel
    }()
    
    lazy var commentsViewButton : UIButton = {
        let viewComments = UIButton(type: .system)
        viewComments.setImage(#imageLiteral(resourceName: "commentBubble").withRenderingMode(.alwaysOriginal), for: .normal)
        viewComments.setTitleColor(.white, for: .normal)
        viewComments.addTarget(self, action: #selector(presentComments), for: .touchUpInside)
        return viewComments
    }()
    
    
    func presentComments(){
        print("Comments button pressed")
        commentsController.eventKey = eventKey
        newCommentsController.eventKey = eventKey
        present(newCommentsController, animated: true, completion: nil)
        
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
    
    
    func handleAttend(){
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
    
    func beginAddToStory(){
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
    
    func handleViewStory(){
        print("Attempting to view story")
        eventStory.eventKey = self.eventKey
        present(eventStory, animated: true, completion: nil)
    }
    
//    lazy var eventTimeLabel:UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.white
//        label.font = UIFont.boldSystemFont(ofSize: 15.0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        return label
//    }()
//
//    lazy var eventDateLabel:UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14.0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        return label
//    }()
//
//    lazy var eventDateTimeView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.blue
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 5.0
//
//        view.addSubview(self.eventDateLabel)
//        NSLayoutConstraint.activateViewConstraints(self.eventDateLabel, inSuperView: view, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: nil)
//        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: self.eventDateLabel, referenceView: view, multiplier: 0.5)
//
//        view.addSubview(self.eventTimeLabel)
//        NSLayoutConstraint.activateViewConstraints(self.eventTimeLabel, inSuperView: view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: 0.0)
//        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: self.eventTimeLabel, referenceView: view, multiplier: 0.5)
//
//        let middleBar = UIView()
//        middleBar.translatesAutoresizingMaskIntoConstraints = false
//        middleBar.backgroundColor = .white
//        view.addSubview(middleBar)
//        NSLayoutConstraint.activateViewConstraints(middleBar, inSuperView: view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 1.0)
//        _ = NSLayoutConstraint.activateCentreYConstraint(withView: middleBar, superView: view)
//        return view
//    }()
    

    
    func swipeAction(_ swipe: UIGestureRecognizer){
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
        self.setupViews()
        
        
//        self.navigationItem.hidesBackButton = true
//        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
//        self.navigationItem.leftBarButtonItem = backButton
        
        //Subviews will be added here
//        view.addSubview(currentEventDate)
        
        //        view.addSubview(attendCount)
        //        view.addSubview(commentCount)
        
        //Constraints will be added here
        
        
//        _ = currentEventDate.anchor(top: currentEventImage.bottomAnchor, left: userInteractStackView?.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 90, height: 50)
        //          _ = attendCount.anchor(top: attendingButton.bottomAnchor, left: commentCount.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 60, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        //        _ = commentCount.anchor(top: commentsViewButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        //        _ = addToStoryButton.anchor(top: stackView?.bottomAnchor, left: attendingButton.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 40, height: 30)
        //        _ = viewStoryButton.anchor(top: stackView?.bottomAnchor, left: addToStoryButton.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        //        viewStoryButton.layer.cornerRadius = 40/2
        attendingButton.isSelected = (currentEvent?.isAttending)!
//        setupEventDisplayScreen()
//        userInteractionView()
        
        // navigationController?.isHeroEnabled = true
    }
    
    private func setupViews() {
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        view.backgroundColor = UIColor.white
        
        view.addSubview(currentEventImage)
        NSLayoutConstraint.activateViewConstraints(currentEventImage, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 200.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topLayoutGuide, secondView: currentEventImage, andSeparation: 0.0)
        
        self.view.addSubview(self.eventNameLabel)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.currentEventImage, secondView: self.eventNameLabel, andSeparation: 10.0)
        NSLayoutConstraint.activateViewConstraints(self.eventNameLabel, inSuperView: self.view, withLeading: 15.0, trailing: -15.0, top: nil, bottom: nil)
        _ = NSLayoutConstraint.activateHeightConstraint(view: self.eventNameLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)
        
        let locationIcon = UIImageView(image: #imageLiteral(resourceName: "marker-black"))
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(locationIcon)
        NSLayoutConstraint.activateViewConstraints(locationIcon, inSuperView: self.view, withLeading: 15.0, trailing: nil, top: nil, bottom: nil, width: 24.0, height: 24.0)
        self.view.addSubview(self.addressLabel)
        self.addressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addressLabel.numberOfLines = 0
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.eventNameLabel, secondView: self.addressLabel, andSeparation: 8.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: locationIcon, secondView: self.addressLabel, andSeparation: 8.0)
        _ = NSLayoutConstraint.activateTrailingConstraint(withView: self.addressLabel, superView: self.view, andSeparation: -15.0)
        _ = NSLayoutConstraint.activateHeightConstraint(view: self.addressLabel, withHeight: 24.0, andRelation: .greaterThanOrEqual)
        _ = NSLayoutConstraint.activateCentreYConstraint(withView: locationIcon, superView: self.addressLabel)
        
        let timeIcon = UIImageView(image: #imageLiteral(resourceName: "date-range"))
        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(timeIcon)
        NSLayoutConstraint.activateViewConstraints(timeIcon, inSuperView: self.view, withLeading: 15.0, trailing: nil, top: nil, bottom: nil, width: 24.0, height: 24.0)
        self.view.addSubview(self.currentEventDateTime)
        self.currentEventDateTime.numberOfLines = 0
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.addressLabel, secondView: self.currentEventDateTime, andSeparation: 8.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: timeIcon, secondView: self.currentEventDateTime, andSeparation: 8.0)
        _ = NSLayoutConstraint.activateTrailingConstraint(withView: self.currentEventDateTime, superView: self.view, andSeparation: -15.0)
        _ = NSLayoutConstraint.activateHeightConstraint(view: self.currentEventDateTime, withHeight: 24.0, andRelation: .greaterThanOrEqual)
        _ = NSLayoutConstraint.activateCentreYConstraint(withView: timeIcon, superView: self.currentEventDateTime)
        
        self.view.addSubview(descriptionLabel)
        NSLayoutConstraint.activateViewConstraints(descriptionLabel, inSuperView: self.view, withLeading: 15.0, trailing: -15.0, top: nil, bottom: nil)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.currentEventDateTime, secondView: descriptionLabel, andSeparation: 10.0)
        
        self.userInteractionView()
        self.userInteractStackView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateViewConstraints(userInteractStackView!, inSuperView: self.view, withLeading: 15.0, trailing: -15.0, top: nil, bottom: -15.0, width: nil, height: 50.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.descriptionLabel, secondView: self.userInteractStackView!, andSeparation: 10.0)
    }
    
//    fileprivate func setupEventDisplayScreen(){
//        stackView = UIStackView(arrangedSubviews: [ eventNameLabel,addressLabel,descriptionLabel])
//        view.addSubview(stackView!)
//        stackView?.distribution = .fill
//        stackView?.axis = .vertical
//        stackView?.spacing = 5.0
//        stackView?.anchor(top: currentEventImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 250)
//    }
    
    fileprivate func userInteractionView(){
        userInteractStackView = UIStackView(arrangedSubviews: [commentsViewButton, attendingButton, addToStoryButton, viewStoryButton])
        viewStoryButton.heightAnchor.constraint(equalToConstant: 50)
        viewStoryButton.widthAnchor.constraint(equalToConstant: 50)
        viewStoryButton.layer.cornerRadius = 150/2
        view.addSubview(userInteractStackView!)
        userInteractStackView?.distribution = .fillEqually
        userInteractStackView?.axis = .horizontal
        userInteractStackView?.spacing = 10.0
        //userInteractStackView?.anchor(top: stackView?.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
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
