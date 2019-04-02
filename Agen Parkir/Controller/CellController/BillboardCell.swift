//
//  BillboardCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 02/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class BillboardCell: UICollectionViewCell {
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {        
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 3
    }
    
    var billboardData: BillboardModel? {
        didSet {
            if let data = billboardData {
                if data.image == "" {
                    image.image = UIImage(named: "Artboard 9@0.75x-8")
                } else {
                    let url = "\(StaticVar.root_images)\(data.image ?? "")"
                    print("billboard cell img url \(url)")
                    image.loadUrl(url)
                }
            }
        }
    }
    
}
