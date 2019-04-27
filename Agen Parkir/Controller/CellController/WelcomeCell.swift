//
//  WelcomeCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class WelcomeCell: UICollectionViewCell {
    @IBOutlet weak var imageHeader: UIImageView!
    
    override func awakeFromNib() {
    }
    
    var welcomeModel: WelcomeModel? {
        didSet {
            if let data = welcomeModel {
                imageHeader.image = UIImage(named: data.imageHeader!)
            }
        }
    }
}
