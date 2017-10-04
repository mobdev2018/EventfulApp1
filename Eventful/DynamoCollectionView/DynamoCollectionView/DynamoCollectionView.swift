//
//  DynamoCollectionView.swift
//  DynamoCollectionView
//
//  Created by Thang Pham on 10/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol DynamoCollectionViewDataSource: NSObjectProtocol {
    func topViewRatio(_ dynamoCollectionView: DynamoCollectionView) -> CGFloat // ratio in range [0,1]
    func numberOfItems(_ dynamoCollectionView: DynamoCollectionView) -> Int
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell
}

protocol DynamoCollectionViewDelegate: NSObjectProtocol {
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, didSelectItemAt indexPath: IndexPath)
}

class DynamoCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Variables
    
    public var delegate: DynamoCollectionViewDelegate?
    public var dataSource: DynamoCollectionViewDataSource?
    private var topView: DynamoCollectionViewCell!
    private var collectionView: UICollectionView!
    private var topViewRatio: CGFloat = 0.7
    private var numberOfItems: Int = 0
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initViews() {
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: (1 - topViewRatio)*bounds.height))
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    public func reloadData() {
        configureView()
    }
    
    // MARK: - View Configuration
    
    private func configureView() {
        if let source = dataSource {
            topViewRatio = min(max(0, source.topViewRatio(self)), 1.0)
            numberOfItems = max(source.numberOfItems(self), 0)
            topView = source.dynamoCollectionView(self, cellForItemAt: IndexPath(item: 0, section: 0))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            topView.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: - CollectionView
    // MARK: CollectionView Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0, numberOfItems - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let source = dataSource {
            return source.dynamoCollectionView(self, cellForItemAt: IndexPath(item: indexPath.item + 1, section: 0))
        }else {
            return DynamoCollectionViewCell() as UICollectionViewCell
        }
    }
    
    // MARK: CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewDelegate = delegate {
            viewDelegate.dynamoCollectionView(self, didSelectItemAt: IndexPath(item: indexPath.item + 1, section: 0))
        }
    }
    
    // MARK: - Gesture Recognizer
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let viewDelegate = delegate {
                viewDelegate.dynamoCollectionView(self, didSelectItemAt: IndexPath(item: 0, section: 0))
            }
            break
        default:
            break
        }
    }
}

