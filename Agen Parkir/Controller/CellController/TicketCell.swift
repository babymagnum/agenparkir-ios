//
//  TicketCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 18/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class TicketCell: UICollectionViewCell {
    
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var dataTicket: TicketModel? {
        didSet{
            if let data = dataTicket {
                if data.images == "" {
                    imageHeader.image = UIImage(named: "Artboard 12@0.75x-8")
                } else {
                    imageHeader.loadUrl("\(StaticVar.root_images)\(data.images ?? "")")
                }
                title.text = data.name
                date.text = data.schedule
            }
        }
    }
    
    override func awakeFromNib() {
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowRadius = 2
    }
}
