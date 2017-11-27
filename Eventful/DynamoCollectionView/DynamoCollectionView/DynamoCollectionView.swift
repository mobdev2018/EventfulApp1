//
//  DynamoCollectionView.swift
//  DynamoCollectionView
//
//  Created by Shawn Miller on 10/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

public protocol DynamoCollectionViewDataSource: NSObjectProtocol {
    func topViewRatio(_ dynamoCollectionView: DynamoCollectionView) -> CGFloat // ratio in range [0,1]
    func numberOfItems(_ dynamoCollectionView: DynamoCollectionView) -> Int
    //Aaks datasource object for the number of items in the specified section
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell
    //Asks datasource object for the cell that corresponds to the specified item in the collectionView
}

public protocol DynamoCollectionViewDelegate: NSObjectProtocol {
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, didSelectItemAt indexPath: IndexPath)
    //Tells the delegate that the item at the specified index path was selected
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, willDisplay cell: UICollectionViewCell, indexPath: IndexPath)
    //Tells the delegate that the specified cells is about to be displayed
}

//A public immutable variable that contains the name of some notification that will be broadcast to some registered observer
public let DynamoCollectionViewEnableScrollingNotification = NSNotification.Name("DynamoCollectionViewEnableScrollingNotification")

//A public immutable variable that contains the name of some notification that will be broadcast to some registered observer
public let DynamoCollectionViewDisableScrollingNotification = NSNotification.Name("DynamoCollectionViewDisableScrollingNotification")

public class DynamoCollectionView: UIView, DynamoCollectionViewCellDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Variables
    //variable to control and make use of the DynamoCollectionViewDelegate
    public var delegate: DynamoCollectionViewDelegate?
    //variable to control and make use of the DynamoCollectionViewDatasource
    public var dataSource: DynamoCollectionViewDataSource?
    //variable to control and make use of the specfic collectionViewCell which happens to be a DynamicCollectionViewCell (See file for implementation)
    private var topView: DynamoCollectionViewCell!
    //variable that will instantiate and let you manage a collectionView inside this view
    private var collectionView: UICollectionView!
    //variable that will instantiate and manage the specific UIView that this class will reference
    private var containerView: UIView!
   //the topViewRatio that will be used in the appropriate delegate method to create some type of spacing beteween views
    private var topViewRatio: CGFloat = 0.6
    // the default numberOfItems that will be used in the appropriate datasource method to managa the number of items in the collectionView
    private var numberOfItems: Int = 0
    //a cell identifier that will let you register a unique instance of a dynamoCollectionViewCell
    private let dynamoCollectionViewCellIdentifier = "DynamoCollectionViewCellIdentifier"
   
    // MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    public func initViews() {
        
        // init topview
        //so topview is literally just the first square
        //will take a variable of type DynamoCollectionViewCell; instantiate it,set it up and set it equal to topView for further referencing and editing
        //Begin to create auto scroll view here
        
        topView = DynamoCollectionViewCell(frame: .zero)
        topView.translatesAutoresizingMaskIntoConstraints = false
        //sets the backgroundcolor of the topView to white
        topView.backgroundColor = UIColor.white
        //sets the delegate of the cell to self. By doing this all messages in regards to the topView cell be sent to the topView or you.
        //"Delegates send messages"
        topView.delegate = self
        //sets the tag to Zero so that we know it is the top cell we are controlling
        topView.tag = 0
        //adds the topView to the view
        addSubview(topView)
        //positions the the topView and controls with and height
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: topView, superView: self)
        _ = NSLayoutConstraint.activateCentreYConstraint(withView: topView, superView: self)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: topView, referenceView: self)
        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: topView, referenceView: self)
        
        // init containerview
        //creates a containerView which will usually serve the function of holding multiple views in it.
        //Most likely the view that will contain the bottom scroll cells that you see in the home feed screen
        containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        addSubview(containerView)
        
        NSLayoutConstraint.activateViewConstraints(containerView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: nil, bottom: 0.0, width: nil, height: nil)
        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: containerView, referenceView: self, multiplier: (1.0 - topViewRatio))
        
        // init collectionview
        //this collectionView is the bottom scrollable view
        //creates a layout variable and sets it equal to UICollectionViewFlowLayout. We need this to create it properly this is just practice
        let layout = UICollectionViewFlowLayout()
        //sets the scroll direction for this specfic collectionView
        layout.scrollDirection = .horizontal
        //creates/instantiates the collectionView so we can further reference and make use of it
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //A Boolean value that determines whether the view’s autoresizing mask is translated into Auto Layout constraints.
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        //sets the datsource of the collectionView to you so you can control where the data gets pulled from
        collectionView.dataSource = self
        //sets the delegate of the collectionView to self. By doing this all messages in regards to the  collectionView will be sent to the collectionView or you.
        //"Delegates send messages"
        collectionView.delegate = self
        //sets the background color of the bottom UIView/CollectionView to white
        collectionView.backgroundColor = .white
        
        backgroundColor = .white
        //adds the collectionView to the ContainerView
        containerView.addSubview(collectionView)
        //positions the collectionView inside of the containerView
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: collectionView, superView: containerView)
        _ = NSLayoutConstraint.activateCentreYConstraint(withView: collectionView, superView: containerView)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: collectionView, referenceView: containerView)
        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: collectionView, referenceView: containerView)
        //registers a DynamoCollectionViewCell inside of the collectionVieww that we previously created
        collectionView.register(DynamoCollectionViewCell.self, forCellWithReuseIdentifier: dynamoCollectionViewCellIdentifier)
        
        // init view's gestures
        
        //will create a pan gesture inside the collection/ContainerView
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panGesture.delaysTouchesBegan = false
        //sets the delegate of the panGesture to self. By doing this all messages in regards to the  panGesture will be sent to the panGesture or you.
        //"Delegates send messages"
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(panGesture)
    }
    
    // MARK: Gesture Recognizers
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    }
    //Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //Ask the delegate if a gesture recognizer should receive an object representing a touch.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint  = touch.location(in: containerView)
        if touchPoint.y > 0 {
           // Creates a notification with a given name and sender and posts it to the notification center.
             //The Notification center A notification dispatch mechanism that enables the broadcast of information to registered observers.
            NotificationCenter.default.post(name: DynamoCollectionViewEnableScrollingNotification, object: nil)
            return true
        }
        //Creates a notification with a given name and sender and posts it to the notification center.
        //The Notification center A notification dispatch mechanism that enables the broadcast of information to registered observers.
        NotificationCenter.default.post(name: DynamoCollectionViewDisableScrollingNotification, object: nil)
        return false
    }
    
    // MARK: Public API
    //reloads the data in the views so we can recieve more content as database updates or we return to the screen from another
    public func reloadData() {
        configureView()
    }
    
    //Returns a reusable table-view cell object located by its identifier.
    //Returns a DynamaoCollectionViewCell specifically
    public func dequeueReusableCell(for indexPath: IndexPath) -> DynamoCollectionViewCell {
        //if the indexpath.item is 0 or in other words you are the top big cell it will return the topView
        //Shawn please change here to add the functionality you want with the auto scrolling
        if indexPath.item == 0 {
            return topView
        }else {
            //else do the proper dequeueReusable cell functionality because we will need multiple of them unlike the top one which seemingly only needs one at the momnent
            return collectionView.dequeueReusableCell(withReuseIdentifier: dynamoCollectionViewCellIdentifier, for: IndexPath(item: indexPath.item - 1, section: 0)) as! DynamoCollectionViewCell
        }
    }
    
    public func invalidateLayout() {
        //Invalidates the current layout and triggers a layout update.
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - View Configuration
    
    private func configureView() {
        //utilizes downcasting to check and assign a value at the same time for proper use
        // will force it to be of type datasource and will only work and execute that block inside if statement if it is
        if let source = dataSource {
            //use the info pullede from source to reconfigure the view
            topViewRatio = min(max(0, source.topViewRatio(self)), 1.0)
            numberOfItems = max(source.numberOfItems(self), 0)
            if numberOfItems > 0 {
                //may need to change this to seems to set the topView back to a dynamic collectionView with one item or sets the tag to zero as well as setting the section number back to 0 and returns that cell
                topView = source.dynamoCollectionView(self, cellForItemAt: IndexPath(item: 0, section: 0))
                //reloads the collectionView
                collectionView.reloadData()
            }
        }
    }
    
    // MARK: DynamoCollectionViewCell Delegate
    
    func dynamoCollectionViewCellDidSelect(sender: UICollectionViewCell) {
        if let viewDelegate = delegate {
            viewDelegate.dynamoCollectionView(self, didSelectItemAt: IndexPath(item: sender.tag, section: 0))
        }
    }
}

//methods for collectionView that is inside of containerView
extension DynamoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    // MARK: CollectionView Datasource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0, numberOfItems - 1)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let source = dataSource {
            let cell = source.dynamoCollectionView(self, cellForItemAt: IndexPath(item: indexPath.item + 1, section: 0))
            cell.tag = indexPath.item + 1
            cell.delegate = self
            return cell
        }else {
            let cell = DynamoCollectionViewCell()
            cell.tag = indexPath.item + 1
            cell.delegate = self
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.dynamoCollectionView(self, willDisplay: cell, indexPath: indexPath)
    }
    
    //Asks the delegate for the size of the header view in the specified section.
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    //Asks the delegate for the size of the footer view in the specified section.
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    //Asks the delegate for the size of the specified item’s cell.
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/2.2, height: collectionView.bounds.size.height)
    }
    //Asks the delegate for the margins to apply to content in the specified section.
//in short in controls the amount of space between the items above,left,right, and below
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    //Asks the delegate for the spacing between successive rows or columns of a section.
    //controls the space in between rows and columns
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    //Asks the delegate for the spacing between successive items of a single row or column.
//controls the space between each cell
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: CollectionView Delegate
    //tells the delegate that the item at the specified index path was selected
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

