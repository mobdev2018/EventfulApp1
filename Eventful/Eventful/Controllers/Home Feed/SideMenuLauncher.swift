//
//  SideMenuLauncher.swift
//  Eventful
//
//  Created by Shawn Miller on 4/2/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideMenuLauncher: NSObject, UICollectionViewDelegateFlowLayout {
    override init() {
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SideMenuCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(SideMenuHeader.self, forCellWithReuseIdentifier: headerID)
    }
    let collectionView :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    let sideMenu: [SideMenu] = {
        return[SideMenu(name: "Seize The Night"),SideMenu(name: "Seize The Day"),SideMenu(name:"21 & Up"), SideMenu(name: "Friends Events")]
    }()
    var homeFeedController: HomeFeedController?
    let cellID = "cellID"
    let headerID = "headerID"
    let blackView = UIView()

    @objc func presentSideMenu(){
        print("Button pressed")
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            window.addSubview(blackView)
            window.addSubview(collectionView)
            collectionView.frame = CGRect(x: 0, y: 0, width: 0, height: window.frame.height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: 0, width: window.frame.width/2, height: self.collectionView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(sideMenu: SideMenu){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: -(window.frame.width), y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }, completion: { (completed: Bool) in
            if sideMenu.name != "" {
                self.homeFeedController?.showControllerForCategory(sideMenu: sideMenu)
            }
        })
    }
}

extension SideMenuLauncher: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return sideMenu.count
        } else{
            return 1
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            return CGSize(width: collectionView.frame.width, height:40)
        } else{
            return CGSize(width: collectionView.frame.width, height:90)
            
        }

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SideMenuCell
            cell.sideMenu = sideMenu[indexPath.item]
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerID, for: indexPath) as! SideMenuHeader
            cell.user = User.current
            cell.dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let sideMenuTitle = self.sideMenu[indexPath.item]
            handleDismiss(sideMenu: sideMenuTitle)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
             return UIEdgeInsets(top: 25, left: 0, bottom: 5, right: 0)
        }else {
            return UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        }
    }
}

extension SideMenuLauncher: UICollectionViewDelegate {
    
}
