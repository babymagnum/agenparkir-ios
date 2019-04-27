//
//  BookingPlateCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 09/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class BookingPlateCell: UICollectionViewCell {
    
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var plate: UILabel!
    @IBOutlet weak var viewIcon: UIView!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        PublicFunction.instance.changeTintColor(imageView: icon, hexCode: 0xffffff, alpha: 1)
        viewIcon.layer.cornerRadius = viewIcon.frame.width / 2
    }
    
    var plateData: PlateModel? {
        didSet {
            if let data = plateData {
                plate.text = "\(data.number_plate ?? "") / \(data.title_plate ?? "")"
                
                if data.vehicle_id == 1 {
                    icon.image = UIImage(named: "scooter")?.tinted(with: UIColor(rgb: 0xffffff))
                } else {
                    icon.image = UIImage(named: "car")?.tinted(with: UIColor(rgb: 0xffffff))
                }
            }
        }
    }
}
