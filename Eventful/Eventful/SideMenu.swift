//
//  SideMenu.swift
//  SideMenu
//
//  Created by IPS on 27/03/17.
//  Copyright © 2017 itpathsolution. All rights reserved.
//

import UIKit

enum position {
    case rightToLeft
    case leftToRight
}

protocol SideMenuDelegate {
    func didSelectItemInSidemenu(index:Int)
}

class SideMenu:UIView,UIGestureRecognizerDelegate{

    static var delegate:SideMenuDelegate?
    static let shared = SideMenu()
    static var openingPosition:position = .rightToLeft
    
    static var disablerView:UIView={ // disables user interaction below the size menu
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
  
        let tap = UITapGestureRecognizer(target: SideMenu.self, action:#selector(hide))
        tap.delegate = shared
        view.addGestureRecognizer(tap)
        
        let swip = UISwipeGestureRecognizer(target: SideMenu.self, action: #selector(hide))
        swip.delegate = shared
        swip.direction = openingPosition == .rightToLeft ? .right : .left
        view.addGestureRecognizer(swip)
        return view
    }()
    
    
    static let viewToShowOnSideMenu = ViewToShowOnSideMenu()
    
    static var containerView:UIView={ // Container view which contains every object of the side menu such as collection view
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        
        view.addSubview(viewToShowOnSideMenu)
        viewToShowOnSideMenu.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        return view
    }()
    
    static var yPositionOfContainerView:NSLayoutConstraint?
    
    static let widthOfContainer = UIScreen.main.bounds.width // visible part of side menu
  
    static func getStartDateEndDate()->(startDate:Date,endDate:Date){
        var currentDate = Date()
        if let value = UserDefaults.standard.object(forKey: "startingDateForEvents") as? Date{
            currentDate = value
        }
        let df = DateFormatter()
        df.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        df.dateFormat = "MM/dd/yyyy"
        
        return (df.date(from: df.string(from: currentDate))!,df.date(from: df.string(from: currentDate.addingTimeInterval(7*24*60*60)))!)
    }
    
    static func show(){
        if let app = UIApplication.shared.delegate as? AppDelegate , let keyWindow = app.window{ // Application winow which can be acces from anywhere
            
            disablerView.backgroundColor = UIColor.init(white: 0, alpha: 0) // Always will be clear to show animation
            
            keyWindow.addSubview(disablerView)
            
            
            disablerView.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0).isActive = true
            disablerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0).isActive = true
            disablerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 0).isActive = true
            disablerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: 0).isActive = true
            
            if !disablerView.subviews.contains(containerView){
               
                disablerView.addSubview(containerView)
                containerView.heightAnchor.constraint(equalToConstant: keyWindow.frame.height).isActive = true
                disablerView.addConstraintsWithFormatt("H:|[v0]|", views: containerView)
                
                yPositionOfContainerView = containerView.topAnchor.constraint(equalTo: disablerView.bottomAnchor, constant: 0)
                disablerView.addConstraint(yPositionOfContainerView!)
                
            }
            keyWindow.layoutIfNeeded()
            yPositionOfContainerView?.constant = -keyWindow.frame.height
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                disablerView.backgroundColor = UIColor.init(white: 0.2, alpha: 0.5)
                keyWindow.layoutIfNeeded()
            }, completion: { (bool) in})
            
        }
    }
    
    @objc static func hide(animationTime:TimeInterval = 0.4){
        
        yPositionOfContainerView?.constant = 0
      
        UIView.animate(withDuration: animationTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            disablerView.backgroundColor = UIColor.init(white: 0, alpha: 0)
            if let app = UIApplication.shared.delegate as? AppDelegate , let keyWindow = app.window{
                keyWindow.layoutIfNeeded()
            }
       
        }, completion: { (bool) in
            
            disablerView.removeFromSuperview() // removing to from keyWindow
        
        })
    }
    
    
    //MARK: Gesture delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == SideMenu.disablerView ? true : false
    }
}

//look here
class ViewToShowOnSideMenu:UIView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
   
    static var isContainingImage = true
    static let shared = ViewToShowOnSideMenu()
    static var imageDataSouce = [#imageLiteral(resourceName: "home"),#imageLiteral(resourceName: "night"),#imageLiteral(resourceName: "summer"),#imageLiteral(resourceName: "suit"),#imageLiteral(resourceName: "college"),#imageLiteral(resourceName: "21"),#imageLiteral(resourceName: "icons8-User Filled-50")]
    static var titleDataSouce = ["Home","Seize The Night", "Seize The Day","Dress To Impress","I Love College","21 & Up","Friend's Events"] {
        didSet{
            ViewToShowOnSideMenu.listingCollectionView.reloadData()
        }
    }
    let intialSpacing:CGFloat = 50
    static var selectedCell = 0

    let cellId = "cellId"
    static var listingCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = true
        cv.backgroundColor = .clear
        return cv
    }()
    
    lazy var headerLabel:UILabel={
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.text = "Filters"
        label.isUserInteractionEnabled = true
        let sep = UIView()
        sep.backgroundColor = .lightGray
        label.addSubview(sep)
        label.addConstraintsWithFormatt("H:|[v0]|", views: sep)
        label.addConstraintsWithFormatt("V:[v0(0.3)]|", views: sep)
        //the hide pressed button wll hide the side menu
        ///it will actually look like an X in the app and not a hide button
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "close_black").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(self.hidePressed), for: .touchUpInside)
        label.addSubview(button)
        label.addConstraintsWithFormatt("H:[v0(30)]-10-|", views: button)
        label.addConstraintsWithFormatt("V:[v0(30)]-10-|", views: button)
        return label
    }()
    
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        
        ViewToShowOnSideMenu.listingCollectionView.register(HeaderCellForFilterMenu.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell")
        ViewToShowOnSideMenu.listingCollectionView.register(CellForSideMenu.self, forCellWithReuseIdentifier: self.cellId)
        ViewToShowOnSideMenu.listingCollectionView.delegate = self
        ViewToShowOnSideMenu.listingCollectionView.dataSource = self
        
        self.addSubview(ViewToShowOnSideMenu.listingCollectionView)
        self.addSubview(headerLabel)
        headerLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        headerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        ViewToShowOnSideMenu.listingCollectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 0).isActive = true
        ViewToShowOnSideMenu.listingCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        ViewToShowOnSideMenu.listingCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        ViewToShowOnSideMenu.listingCollectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return section == 0 ? ViewToShowOnSideMenu.titleDataSouce.count : 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height:CGFloat = 40
        return CGSize(width: indexPath.section == 0 ? self.frame.width/2-10 : self.frame.width-20, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! CellForSideMenu
        cell.textLabel.text = ViewToShowOnSideMenu.titleDataSouce[indexPath.item].uppercased()
        if ViewToShowOnSideMenu.selectedCell == indexPath.row,indexPath.section == 0 {
            cell.textLabel.layer.borderColor = UIColor.blue.cgColor
        }else{
            cell.textLabel.layer.borderColor = UIColor.lightGray.cgColor
            if indexPath.section == 1{
                let df = DateFormatter()
                df.dateFormat = "MM/dd/yyyy"
                df.timeZone = NSTimeZone(name: "UTC") as TimeZone!
                cell.textLabel.text = df.string(from: SideMenu.getStartDateEndDate().startDate) + " to " + df.string(from: SideMenu.getStartDateEndDate().endDate)
           
            }
            
            
        }
      
  return cell
    }
   
    
   
    //will handle the action to take on selection of one of the cells in the side menu
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            DatePickerView.show()
        }else{
            SideMenu.hide(animationTime: indexPath.item != ViewToShowOnSideMenu.titleDataSouce.count-1 ? 0.4 : 0)
            if indexPath.item == 6{
                
                //sets the top controller to the current viewController
                var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                while (topController.presentedViewController != nil) {
                    topController = topController.presentedViewController!
                }
                let dvc = UINavigationController(rootViewController: FriendsEventsView())
                topController.present(dvc, animated: true, completion: {
                })
                return
            }else if indexPath.item != ViewToShowOnSideMenu.selectedCell,indexPath.item != ViewToShowOnSideMenu.titleDataSouce.count-1{
                ViewToShowOnSideMenu.selectedCell = indexPath.item
                collectionView.reloadData()
                SideMenu.delegate?.didSelectItemInSidemenu(index: indexPath.item)
            }
            
        }
   
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
     
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! HeaderCellForFilterMenu
         if indexPath.section == 0{
            cell.label.text = "Categories"
        }else{
            cell.label.text = "Events Date"
        }
        
        return cell
        
    }
    
    @objc func hidePressed(){
        SideMenu.hide()
        SideMenu.delegate?.didSelectItemInSidemenu(index: ViewToShowOnSideMenu.selectedCell)
    }
}


class CellForSideMenu:UICollectionViewCell{
    
    let textLabel:UILabel={
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 4
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.lightGray.cgColor
        return label
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(textLabel)
        self.addConstraintsWithFormatt("H:|-2-[v0]-6-|", views: textLabel)
        self.addConstraintsWithFormatt("V:|-2-[v0]-4-|", views: textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class HeaderCellForFilterMenu:UICollectionReusableView{
    let label:UILabel={
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        backgroundColor = .white
        addConstraintsWithFormatt("H:|[v0]|", views: label)
        addConstraintsWithFormatt("V:|[v0]|", views: label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}







protocol CustomDatePickerDeledate:class{
    
    func didTappedDoneButton(selectedDate:Date)
}

class DatePickerView{
    
    static let datePicker:UIDatePicker={
        let dpv = UIDatePicker()
        dpv.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        dpv.translatesAutoresizingMaskIntoConstraints = false
        dpv.datePickerMode = .date
        return dpv
    }()
    static var delegate:CustomDatePickerDeledate?
    static var yPosConstraint:NSLayoutConstraint?
    static var topActionHeight:CGFloat = 40
    static var totalHeight:CGFloat = 130+topActionHeight
    static let containerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        return view
    }()
    
    static let actionView:UIView={
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    static let cancelButton:UIButton={
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .clear
        button.setTitle("Cancel", for:.normal)
        button.addTarget(DatePickerView.self, action: #selector(DatePickerView.cancelButtonClicked), for: .touchUpInside)
        return button
    }()
    
    static let doneButton:UIButton={
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .clear
        button.setTitle("Done", for:.normal)
        button.addTarget(DatePickerView.self, action: #selector(DatePickerView.doneButtonClicked), for: .touchUpInside)
        return button
        
    }()
    
    static func show(){
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window  {
            
            keyWindow.addSubview(containerView)
            keyWindow.addConstraintsWithFormatt("H:|[v0]|", views: containerView)
            keyWindow.addConstraintsWithFormatt("V:|[v0]|", views: containerView)
            
            containerView.addSubview(datePicker)
            
            containerView.addSubview(actionView)
            actionView.rightAnchor.constraint(equalTo: datePicker.rightAnchor, constant: 0).isActive = true
            actionView.heightAnchor.constraint(equalToConstant: topActionHeight).isActive = true
            actionView.leftAnchor.constraint(equalTo: datePicker.leftAnchor, constant: 0).isActive = true
            actionView.bottomAnchor.constraint(equalTo: datePicker.topAnchor).isActive = true
            
            actionView.addSubview(cancelButton)
            actionView.addSubview(doneButton)
            cancelButton.topAnchor.constraint(equalTo: actionView.topAnchor).isActive = true
            cancelButton.bottomAnchor.constraint(equalTo: actionView.bottomAnchor).isActive = true
            cancelButton.leftAnchor.constraint(equalTo: actionView.leftAnchor).isActive = true
            cancelButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            doneButton.topAnchor.constraint(equalTo: actionView.topAnchor).isActive = true
            doneButton.bottomAnchor.constraint(equalTo: actionView.bottomAnchor).isActive = true
            doneButton.rightAnchor.constraint(equalTo: actionView.rightAnchor).isActive = true
            doneButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            datePicker.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
            datePicker.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
            yPosConstraint = datePicker.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
            containerView.addConstraint(yPosConstraint!)
            
            //adding top action sheet
            
            keyWindow.layoutIfNeeded()
            
            yPosConstraint?.constant = -totalHeight
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                keyWindow.layoutIfNeeded()
            }, completion: nil)
        }
        
    }
    
    
    @objc static func doneButtonClicked(){
        
        delegate?.didTappedDoneButton(selectedDate: datePicker.date)
        DatePickerView.hideDatePicker()
        
        UserDefaults.standard.set(datePicker.date, forKey: "startingDateForEvents")
        ViewToShowOnSideMenu.listingCollectionView.reloadData()
        
    }
    
    @objc static func hideDatePicker(){
        
        func remove(){
            containerView.removeFromSuperview()
            datePicker.removeFromSuperview()
            actionView.removeFromSuperview()
            doneButton.removeFromSuperview()
            cancelButton.removeFromSuperview()
            delegate = nil
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
            yPosConstraint?.constant = totalHeight
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                keyWindow.layoutIfNeeded()
            }, completion:{ (Bool) in
                remove()
            })
            
        }
    }
    @objc static func cancelButtonClicked(){
        DatePickerView.hideDatePicker()
    }
    
    
    
    
 
}






