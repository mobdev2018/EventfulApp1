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
    
    static func computeComplementaryColor(image: UIImage, at rect:CGRect) -> UIColor {
        
        let colorCube = CCColorCube()
        if let sampleColors = CCImageColors(extractedColors: colorCube.extractDarkColors(from: image, avoid: nil, count: 4)) {
            var hueV = CGFloat(0), saturationV = CGFloat(0), brightnessV = CGFloat(0), alphaV = CGFloat(0)
            sampleColors.color1.getHue(&hueV, saturation: &saturationV, brightness: &brightnessV, alpha: &alphaV)
            return UIColor(hue: 2*CGFloat.pi - hueV, saturation: saturationV, brightness: brightnessV, alpha: alphaV)
        }
        return UIColor.orange
    }

}
