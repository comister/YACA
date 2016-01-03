//
//  UIImage.extension.swift
//  YACA
//
//  Created by Andreas Pfister on 03/01/16.
//  Copyright © 2016 AP. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var blank_x1: UIImage {
        get {
            UIGraphicsBeginImageContextWithOptions(CGRectMake(0, 0, 22, 22).size, false, 0)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}