//
//  DynamoCollectionView.swift
//  DynamoCollectionView
//
//  Created by Thang Pham on 10/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

protocol DynamoCollectionViewDataSource: NSObjectProtocol {
    func topViewRatio(_ dynamoCollectionView: DynamoCollectionView) -> Float // ratio in range [0,1]
    func numberOfItems(_ dynamoCollectionView: DynamoCollectionView) -> Int
    func dynamoCollectionView(_ dynamoCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell
}

protocol DynamoCollectionViewDelegate: NSObjectProtocol {
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, didSelectItemAt indexPath: IndexPath)
}

class DynamoCollectionView: UIView {
    var delegate: DynamoCollectionViewDelegate?
    var dataSource: DynamoCollectionViewDataSource?
    private var topViewRatio: Float = 0.7
    private var numberOfItems: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reloadData() {
        loadView()
    }
    
    private func loadView() {
        guard let source = dataSource else { return }
        topViewRatio = min(max(0, source.topViewRatio(self)), 1.0)
        numberOfItems = max(source.numberOfItems(self), 0)
    }
}

