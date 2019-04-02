//
//  SettingsCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 06/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class SettingsCell: UICollectionViewCell {
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var contentMain: UIView!
    
    var settingsData: SettingsModel? {
        didSet {
            if let data = settingsData {
                label.text = data.label
                self.setIcon(data.id!)
            }
        }
    }
    
    private func setIcon(_ id: Int) {
        switch id {
        case 1:
            image.image = UIImage(named: "Artboard 188@0.75x-8")
        case 2:
            image.image = UIImage(named: "Artboard 190@0.75x-8")
        case 3:
            image.image = UIImage(named: "Artboard 192@0.75x-8")
        case 4:
            image.image = UIImage(named: "Artboard 189@0.75x-8")
        case 5:
            image.image = UIImage(named: "Artboard 191@0.75x-8")
        case 6:
            image.image = UIImage(named: "Artboard 193@0.75x-8")
        default:
            image.image = UIImage(named: "Artboard 194@0.75x-8")
        }
    }
}
