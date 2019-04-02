//
//  ServicesCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 04/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class ServicesCell: UICollectionViewCell {
    
    @IBOutlet weak var viewContentText: UIView!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var servicesName: UILabel!
    @IBOutlet weak var servicesDescription: UILabel!
    @IBOutlet weak var servicesDate: UILabel!
    @IBOutlet weak var iconStar: UIImageView!
    @IBOutlet weak var buttonBuy: UIButton!
    
    override func awakeFromNib() {
        imageHeader.clipsToBounds = true
        imageHeader.layer.cornerRadius = 10
        buttonBuy.clipsToBounds = true
        buttonBuy.layer.cornerRadius = buttonBuy.frame.height / 2
        iconStar.clipsToBounds = true
        iconStar.layer.cornerRadius = iconStar.frame.width / 2
    }
    
    var servicesData: ServicesModel? {
        didSet {
            if let data = servicesData {
                if data.image == "" {
                    imageHeader.image = UIImage(named: "Screen Shot 2019-02-25 at 09.34.30")
                } else { imageHeader.loadUrl("\(StaticVar.root_images)\(data.image!)") }
                
                servicesName.text = data.title
                servicesDescription.text = data.description
                servicesDate.text = data.date
            }
        }
    }
}
