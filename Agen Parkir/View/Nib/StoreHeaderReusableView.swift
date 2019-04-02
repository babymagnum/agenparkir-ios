//
//  StoreHeaderReusableView.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class StoreHeaderReusableView: UICollectionReusableView {
    //MARK: Outlet
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var iconMessage: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imageCategoryWidth: NSLayoutConstraint!
    @IBOutlet weak var imageCategoryHeight: NSLayoutConstraint!
    @IBOutlet weak var dividerHeight: NSLayoutConstraint!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var iconTime: UIImageView!
    @IBOutlet weak var iconFavorite: UIImageView!
    @IBOutlet weak var favorite: UILabel!
    @IBOutlet weak var venueDescription: UILabel!
    @IBOutlet weak var venueAddress: UILabel!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    
    var dataHeader: StoreModel? {
        didSet {
            if let data = dataHeader {
                imageHeader.loadUrl("\(StaticVar.root_images)\(data.images ?? "")")
                let timeArray = data.time?.components(separatedBy: "-")
                venueName.text = data.name_store
                time.text = "Open until \(timeArray![1].trim()) today"
                favorite.text = "Favorite"
                venueDescription.text = data.description
                venueAddress.text = data.address
            }
        }
    }
    
    override func awakeFromNib() {
        iconTime.image = UIImage(named: "clock")?.tinted(with: UIColor.lightGray.withAlphaComponent(0.6))
        viewTop.clipsToBounds = true
        viewTop.layer.cornerRadius = 10
        viewContent.layer.cornerRadius = 10
        viewContent.clipsToBounds = false
        viewContent.layer.shadowColor = UIColor.lightGray.cgColor
        viewContent.layer.shadowRadius = 2
        viewContent.layer.shadowOpacity = 0.6
        viewContent.layer.shadowOffset = CGSize(width: 1, height: 2)
        
    }
}
