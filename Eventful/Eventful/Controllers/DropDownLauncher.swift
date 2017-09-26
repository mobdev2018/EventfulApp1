//
//  DropDownLauncher.swift
//  Eventful
//
//  Created by Shawn Miller on 9/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class DropDownLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    let dropDown: [ImageAndTitleItem] = {
        return [ImageAndTitleItem(name: "Home", imageName: "home"),ImageAndTitleItem(name: "Seize The Night", imageName: "night"),ImageAndTitleItem(name: "Seize The Day", imageName: "summer"), ImageAndTitleItem(name: "Dress To Impress", imageName: "suit"), ImageAndTitleItem(name: "I Love College", imageName: "college"),ImageAndTitleItem(name: "21 & Up", imageName: "21")]
    }()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dropDown.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DropDownCell
        let dropDown = self.dropDown[indexPath.row]
        cell.dropDown = dropDown
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow{
                self.collectionView.frame = CGRect(x: 0, y: -(window.frame.height), width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }) { (completed: Bool) in
            let dropDown = self.dropDown[indexPath.item]
           self.homeFeed?.categoryFetch(dropDown: dropDown)
            print("")
        }
        
    }
    override init(){
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        collectionView.register(DropDownCell.self, forCellWithReuseIdentifier: cellID)
    }
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellID = "cellID"
    let cellHeight:CGFloat = 50
    var homeFeed: HomeFeedController?
    func showDropDown(){
        //show menu
        if let window = UIApplication.shared.keyWindow{
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            window.addSubview(collectionView)
            let height: CGFloat = CGFloat(dropDown.count) * cellHeight
            collectionView.frame = CGRect(x: 0, y: -(window.frame.height), width: window.frame.width, height: height)
            blackView.frame = window.frame
            blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
        }
    }
    func handleDismiss(){
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow{
                self.collectionView.frame = CGRect(x: 0, y: -(window.frame.height), width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        })
    }
}
