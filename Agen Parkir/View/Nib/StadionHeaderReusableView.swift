//
//  StadionHeaderReusableview.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 28/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class StadionHeaderReusableView: UICollectionReusableView {
    //MARK: Outlet
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var totalEvent: UILabel!
    @IBOutlet weak var venueAddress: UILabel!
    
    override func awakeFromNib() {
        contentMain.layer.cornerRadius = 8
        contentMain.clipsToBounds = false
        contentMain.layer.shadowColor = UIColor.lightGray.cgColor
        contentMain.layer.shadowOffset = CGSize(width: 1, height: 2)
        contentMain.layer.shadowRadius = 2
        contentMain.layer.shadowOpacity = 0.6
    }
    
    var venueData: VenueTicketModel? {
        didSet{
            if let data = venueData {
                imageHeader.loadUrl("\(StaticVar.root_images)\(data.images_building ?? "")")
                venueName.text = data.name_building
                totalEvent.text = "\(data.count_event ?? 0) Event On Going"
                venueAddress.text = data.address
            }
        }
    }
}
