//
//  NoConnectionView.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 10/04/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class NibView: UIView {
    
    var contentView: UIView!
    
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
    }
    
    //MARK:
    func loadViewFromNib() {
        contentView = (Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as! UIView)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }
    
}
