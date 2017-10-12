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
    
    static func computeComplementaryColor(image: UIImage) -> UIColor {
        
        if let sampleColors = CCColorCube().extractDarkColors(from: image, avoid: nil, count: 4) {
            var redV = CGFloat(0), greenV = CGFloat(0), blueV = CGFloat(0), alphaV = CGFloat(0)
            (sampleColors[2] as! UIColor).getRed(&redV, green: &greenV, blue: &blueV, alpha: &alphaV)
            let a = 1 - ( 0.299 * redV + 0.587 * greenV + 0.114 * blueV)/255
            if a < 0.5 {
                return UIColor(red: greenV*0.5, green: blueV*0.5, blue: redV*0.5, alpha: 1.0)
            }else {
                return UIColor(red: greenV*2, green: blueV*2, blue: redV*2, alpha: 1.0)
            }
            //var hueV = CGFloat(0), saturationV = CGFloat(0), brightnessV = CGFloat(0), alphaV = CGFloat(0)
            //(sampleColors[0] as! UIColor).getHue(&hueV, saturation: &saturationV, brightness: &brightnessV, alpha: &alphaV)
            //return UIColor(hue: 2*CGFloat.pi - hueV, saturation: saturationV, brightness: brightnessV, alpha: 1.0)
            //return (sampleColors[0] as! UIColor)
        }
        return UIColor.orange
    }

}
