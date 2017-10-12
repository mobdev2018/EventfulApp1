//
//  DynamoUtils.swift
//  DynamoCollectionView
//
//  Created by Thang Pham on 10/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Accelerate

class DynamoUtils {
    
    static func computeComplementaryColor(image: UIImage) -> (UIColor, UIColor) {
        
        if let brightColors = CCColorCube().extractBrightColors(from: image, avoid: nil, count: 4){
            for i in 0..<brightColors.count {
                var redV = CGFloat(0), greenV = CGFloat(0), blueV = CGFloat(0), alphaV = CGFloat(0)
                (brightColors[i] as! UIColor).getRed(&redV, green: &greenV, blue: &blueV, alpha: &alphaV)
                let a = 1 - ( 0.299 * redV + 0.587 * greenV + 0.114 * blueV)/255
                if a > 0.5 && (redV + greenV + blueV) < 2.0 {
                    return (UIColor(red: redV, green: greenV, blue: blueV, alpha: 1.0), UIColor.white)
                }
            }
        }
        return (UIColor.orange, UIColor.white)
    }

}
