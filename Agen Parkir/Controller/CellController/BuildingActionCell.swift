//
//  BuildingActionCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 18/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class BuildingActionCell: UICollectionViewCell {
    @IBOutlet weak var iconBooking: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var contentMain: UIView!
    
    override func awakeFromNib() {
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = contentMain.frame.height / 2
    }
    
    var actionData: String? {
        didSet{
            if let data = actionData{
                actionLabel.text = data
                
                switch data{
                case "Book Parking":
                    iconBooking.image = UIImage(named: "parking")!.tinted(with: UIColor(rgb: 0xffffff))
                case "Buy Ticket":
                    iconBooking.image = UIImage(named: "Artboard 244@54x-8")
                default:
                    iconBooking.image = UIImage(named: "Artboard 242@54x-8")
                }
            }
        }
    }
    
}
