//
//  TabBarController.swift
//  YACA
//
//  Created by Andreas Pfister on 22/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        // Mark: - Switch to Settings in case no UserDefaults set yet
        if (NSUserDefaults.standardUserDefaults().stringForKey("selectedCalendar") == nil) {
            self.selectedIndex = 2
        }
    }
}
