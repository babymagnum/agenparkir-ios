//
//  ReceiptsCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 14/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class ReceiptsCell: UICollectionViewCell {
    
    @IBOutlet weak var viewDividerHeight: NSLayoutConstraint!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    
    override func awakeFromNib() {
        viewDividerHeight.constant = venueName.frame.height + 5 + message.frame.height + 5 + orderDate.frame.height
        
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
    }
    
    var receiptsData: ReceiptsModel? {
        didSet{
            if let data = receiptsData {
                venueName.text = data.building_name
                
                //booking date
                if data.booking_start_time != "" {
                    let dateInMillis = PublicFunction.instance.dateStringToInt(stringDate: data.booking_start_time!, pattern: "yyyy-MM-dd kk:mm:ss")
                    let stringDate = PublicFunction.instance.dateLongToString(dateInMillis: dateInMillis, pattern: "dd MMMM yyyy, kk:mm a")
                    orderDate.text = "\(stringDate)"
                } else {
                    orderDate.text = "Unknowns date"
                }
                
                //status
                switch data.booking_status_id {
                case 0:
                    self.message.text = "Parking Reserved"
                case 1:
                    self.message.text = "Parking Ongoing"
                case 2:
                    self.message.text = "Parking"
                case 3:
                    self.message.text = "Parking Completed"
                default:
                    self.message.text = "Parking Canceled"
                }
            }
        }
    }
}
