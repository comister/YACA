//
//  MeetingListCellHeader.swift
//  YACA
//
//  Created by Andreas Pfister on 16/12/15.
//  Copyright © 2015 Andy P. All rights reserved.
//

import UIKit

class MeetingListCellHeader: UICollectionReusableView {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var verticalLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("having a header")
        rotateLabel()
    }
    
    func rotateLabel() {
        dayLabel?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2)/2)
    }
    
}
