//
//  DynamoCollectionView.swift
//  DynamoCollectionView
//
//  Created by Thang Pham on 10/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

public protocol DynamoCollectionViewDataSource: NSObjectProtocol {
    func topViewRatio(_ dynamoCollectionView: DynamoCollectionView) -> CGFloat // ratio in range [0,1]
    func numberOfItems(_ dynamoCollectionView: DynamoCollectionView) -> Int
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell
}

public protocol DynamoCollectionViewDelegate: NSObjectProtocol {
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, didSelectItemAt indexPath: IndexPath)
}

public class DynamoCollectionView: UIView, DynamoCollectionViewCellDelegate {
    
    // MARK: - Variables
    
    public var delegate: DynamoCollectionViewDelegate?
    public var dataSource: DynamoCollectionViewDataSource?
    private var topView: DynamoCollectionViewCell!
    private var collectionView: UICollectionView!
    private var topViewRatio: CGFloat = 0.6
    private var numberOfItems: Int = 0
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

    private func initViews() {
        
        // init topview
        
        topView = DynamoCollectionViewCell(frame: .zero)
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor.white
        topView.tag = 0
        addSubview(topView)
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: topView, superView: self)
        _ = NSLayoutConstraint.activateCentreYConstraint(withView: topView, superView: self)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: topView, referenceView: self)
        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: topView, referenceView: self)
        
        // init collectionview
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.canCancelContentTouches = true
        backgroundColor = .white
        addSubview(collectionView)
        NSLayoutConstraint.activateViewConstraints(self.collectionView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: nil, bottom: 0.0, width: nil, height: nil)
        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: self.collectionView, referenceView: self, multiplier: (1.0 - topViewRatio))
        collectionView.register(DynamoCollectionViewCell.self, forCellWithReuseIdentifier: dynamoCollectionViewCellIdentifier)
    }
    
    // MARK: Public API
    
    public func reloadData() {
        configureView()
    }
    
    public func dequeueReusableCell(for indexPath: IndexPath) -> DynamoCollectionViewCell {
        if indexPath.item == 0 {
            return topView
        }else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: dynamoCollectionViewCellIdentifier, for: IndexPath(item: indexPath.item - 1, section: 0)) as! DynamoCollectionViewCell
        }
    }
    
    public func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - View Configuration
    
    private func configureView() {
        if let source = dataSource {
            topViewRatio = min(max(0, source.topViewRatio(self)), 1.0)
            numberOfItems = max(source.numberOfItems(self), 0)
            if numberOfItems > 0 {
                topView = source.dynamoCollectionView(self, cellForItemAt: IndexPath(item: 0, section: 0))
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

extension DynamoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    // MARK: CollectionView Datasource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0, numberOfItems - 1)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let source = dataSource {
            let cell = source.dynamoCollectionView(self, cellForItemAt: IndexPath(item: indexPath.item + 1, section: 0))
            cell.tag = indexPath.item + 1
            return cell
        }else {
            let cell = DynamoCollectionViewCell() as UICollectionViewCell
            cell.tag = indexPath.item + 1
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/2.2, height: collectionView.bounds.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: CollectionView Delegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

