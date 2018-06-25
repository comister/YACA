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
        UIView.animate(withDuration: 2.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: nil
        )
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 2.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
            }, completion: nil
        )
    }
}
