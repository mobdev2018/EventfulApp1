////
////  UICollectionView+Utility.swift
////  Eventful
////
////  Created by Shawn Miller on 8/29/17.
////  Copyright © 2017 Make School. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//protocol CellIdentifiable {
//    static var cellIdentifier: String { get }
//}
//
//// 1
//extension CellIdentifiable where Self: UICollectionViewCell {
//    // 2
//    static var cellIdentifier: String {
//        return String(describing: self)
//    }
//}
//
//// 3
//extension UICollectionViewCell: CellIdentifiable { }
//
//extension UICollectionView {
//    // 1
//    func dequeueReusableCell<T: UICollectionViewCell>() -> T where T: CellIdentifiable {
//        // 2
//        guard let cell = dequeueReusableCell(withIdentifier: T.cellIdentifier) as? T else {
//            // 3
//            fatalError("Error dequeuing cell for identifier \(T.cellIdentifier)")
//        }
//        
//        return cell
//    }
//}
