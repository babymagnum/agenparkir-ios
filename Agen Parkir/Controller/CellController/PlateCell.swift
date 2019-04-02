//
//  PlateCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 07/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class PlateCell: UICollectionViewCell {
    
    @IBOutlet weak var iconDelete: UIImageView!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var plateAndName: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        PublicFunction().changeTintColor(imageView: iconDelete, hexCode: 0xdfe6e9, alpha: 1)
    }
    
    var plateData: PlateModel? {
        didSet {
            if let data = plateData {
                plateAndName.text = "\(data.number_plate ?? "") / \(data.title_plate ?? "")"
                
                switch data.vehicle_id {
                case 1: //motor
                    icon.image = UIImage(named: "Artboard 172@0.75x-8")
                default:
                    icon.image = UIImage(named: "Artboard 171@0.75x-8")
                }
            }
        }
    }
}
