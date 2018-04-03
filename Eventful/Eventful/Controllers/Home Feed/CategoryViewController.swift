//
//  CategoryViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 4/3/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CategoryViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout{
    var events = [Event]()
    let cellID = "cellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(CategoryEventCell.self, forCellWithReuseIdentifier: cellID)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    @objc func setupViews(){
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.collectionView?.backgroundColor = .white
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
    }
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)/3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 5, right:0)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryEventCell
        cell.event = events[indexPath.item]
        // Configure the cell
        return cell
    }
    
  

}
