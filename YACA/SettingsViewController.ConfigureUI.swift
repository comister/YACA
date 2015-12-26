//
//  SettingsViewController.ConfigureUI.swift
//  YACA
//
//  Created by Andreas Pfister on 24/12/15.
//  Copyright © 2015 AP. All rights reserved.
//
// MARK: - configure the UI for SettingsViewController
import UIKit

extension SettingsViewController {
    func configureUI() {
        //not configuring Settings screen, looks strange with all this orange here
        /*
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 1, green: 0.680, blue: 0.225, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1, green: 0.594, blue: 0.128, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient!, atIndex: 0)
        */
    }
}