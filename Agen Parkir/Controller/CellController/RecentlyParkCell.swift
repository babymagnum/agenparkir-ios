//
//  RecentlyParkCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 01/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class RecentlyParkCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var contentMain: UIView!
    
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
    
    var recentlyData: RecentlyModel? {
        didSet{
            if let data = recentlyData {
                print("recently url \("\(StaticVar.root_images)\(data.image ?? "")")")
                image.loadUrl("\(StaticVar.root_images)\(data.image ?? "")")
                venueName.text = data.venueName
                orderDate.text = data.orderDate
            }
        }
    }
}
