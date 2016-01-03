//
//  UIView.extension.swift
//  YACA
//
//  Created by Andreas Pfister on 14/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func fadeIn() {

        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
            }, completion: nil)
    }
    
    func fadeOut() {
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.alpha = 0.0
            }, completion: nil)
    }
}