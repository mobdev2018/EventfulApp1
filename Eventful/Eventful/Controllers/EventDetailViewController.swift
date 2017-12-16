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
            guard let currentZip = currentEvent?.currentEventZip else{
                return
            }
            let firstPartOfAddress = (currentEvent?.currentEventStreetAddress)!  + "\n" + (currentEvent?.currentEventCity)! + ", " + (currentEvent?.currentEventState)!
            let secondPartOfAddress = firstPartOfAddress + " " + String(describing: currentZip)
            addressLabel.text = secondPartOfAddress
            descriptionLabel.text = currentEvent?.currentEventDescription
            descriptionLabel.font = UIFont(name: (descriptionLabel.font?.fontName)!, size: 14)
            updateWithSpacing(lineSpacing: 7.0)
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
    
    
    
    
    fileprivate func extractedFunc(_ url: URL?) -> EventPromoVideoPlayer {
        return EventPromoVideoPlayer(videoURL: url!)
    }
    
    @objc func handlePromoVid(){
        print("Image tappped")
        print(eventPromo)
        let url = URL(string: eventPromo)
        let videoLauncher = extractedFunc(url)
        present(videoLauncher, animated: true, completion: nil)
        
        //        self.navigationController?.pushViewController(videoLauncher, animated: true)
        
    }
    
    lazy var currentEventTime: UILabel = {
        let currentEventTime = UILabel()
        currentEventTime.font = UIFont(name: currentEventTime.font.fontName, size: 12)
        return currentEventTime
    }()
    
    
    lazy var currentEventDate: UILabel = {
        let currentEventDate = UILabel()
        currentEventDate.font = UIFont(name: currentEventDate.font.fontName, size: 12)
        return currentEventDate
    }()
    
    
    //will show the event name
    lazy var eventNameLabel: UILabel = {
        let currentEventName = UILabel()
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
        currentDescriptionLabel.isUserInteractionEnabled = false
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
        newCommentsController.comments.removeAll()
        newCommentsController.adapter.reloadData { (updated) in
            
        }
        present(newCommentsController, animated: true, completion: nil)
        
    }
    
    
    lazy var attendingButton: UIButton = {
        let attendButton = UIButton(type: .system)
        attendButton.setImage(#imageLiteral(resourceName: "walkingNotFilled").withRenderingMode(.alwaysOriginal), for: .normal)
        attendButton.addTarget(self, action: #selector(handleAttend), for: .touchUpInside)
        return attendButton
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

        //Subviews will be added here
        view.addSubview(currentEventImage)
        view.addSubview(currentEventDate)

        //Constraints will be added here
        _ = currentEventImage.anchor(top: view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: -305, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.view.frame.width, height: 200)
        _ = currentEventDate.anchor(top: currentEventImage.bottomAnchor, left: stackView?.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 90, height: 50)

        attendingButton.isSelected = (currentEvent?.isAttending)!
        setupEventDisplayScreen()
        userInteractionView()
    }
    
    fileprivate func setupEventDisplayScreen(){
        stackView = UIStackView(arrangedSubviews: [eventNameLabel,addressLabel])
        view.addSubview(stackView!)
        view.addSubview(descriptionLabel)
        stackView?.distribution = .fill
        stackView?.axis = .vertical
        stackView?.spacing = 0.0
        stackView?.anchor(top: currentEventImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 0, paddingRight: 20, width: 0, height: 70)
        descriptionLabel.anchor(top: stackView?.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 90, height: 200)
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
        userInteractStackView?.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
        let ref = Database.database().reference().child("Comments").child(self.eventKey)
        
        ref.observe(.value, with: { (snapshot: DataSnapshot!) in
            var numberOfComments = 0
            numberOfComments = numberOfComments + Int(snapshot.childrenCount)
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: descriptionLabel.text)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = descriptionLabel.text?.characters.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        descriptionLabel.attributedText = attributedString

    }
    
}
