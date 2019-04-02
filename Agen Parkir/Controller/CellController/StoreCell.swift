//
//  StoreCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class StoreCell: UICollectionViewCell {
    //MARK: Outlet
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var dividerHeight: NSLayoutConstraint!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var iconClock: UIImageView!
    @IBOutlet weak var imageHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeaderWidth: NSLayoutConstraint!
    
    //set data
    var storeData: StoreModel? {
        didSet{
            if let data = storeData {
                imageHeader.kf.setImage(with: URL(string: "\(StaticVar.root_images)\(data.images ?? "")"), placeholder: UIImage(named: "Artboard 243@54x-8"))
                storeName.text = data.name_store
                address.text = data.address
                let timeArray = data.time?.components(separatedBy: "-")
                time.text = "Open from \(timeArray![0].trim()) until \(timeArray![1].trim()) today"
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.6
    }
    
    override func awakeFromNib() {
        imageHeader.clipsToBounds = true
        imageHeader.layer.cornerRadius = 8
        dividerHeight.constant = storeName.frame.height + 50
        imageHeaderHeight.constant = storeName.frame.height + 50
        imageHeaderWidth.constant = storeName.frame.height + 50
        
        contentMain.layer.cornerRadius = 8
        iconClock.image = UIImage(named: "clock")?.tinted(with: UIColor.lightGray)
    }
}
