//
//  UpdatesCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 04/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class UpdatesCell: UICollectionViewCell {
    
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var lastUpdated: UILabel!
    @IBOutlet weak var carCount: UILabel!
    @IBOutlet weak var motorCount: UILabel!
    @IBOutlet weak var updateVenue: UIImageView!
    
    var updatesData: BuildingModel? {
        didSet{
            if let data = updatesData{
                venueName.text = data.name_building
                carCount.text = "\(data.motor ?? 0)"
                motorCount.text = "\(data.mobil ?? 0)"
                lastUpdated.text = "1 hour ago"
                index.text = "\(data.index ?? 1)"
            }
        }
    }
}
