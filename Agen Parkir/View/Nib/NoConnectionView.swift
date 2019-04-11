//
//  NoConnectionView.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 10/04/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class NoConnectionView: UIView {

    @IBOutlet weak var contentMain: UIView!
    
    override func awakeFromNib() {
        contentMain.layer.cornerRadius = 5
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
