//
//  MyChatImageCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 30/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class MyChatImageCell: UICollectionViewCell {
    
    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        image.clipsToBounds = true
        image.layer.cornerRadius = 5
        image.layer.borderWidth = 3
        image.layer.borderColor = UIColor(rgb: 0x00A551).cgColor
        
//        let widthConstraint = NSLayoutConstraint(item: image, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self.superview, attribute: .width, multiplier: 1.0, constant: UIScreen.main.bounds.width - 65 - time.frame.width)
//        let heightConstraint = NSLayoutConstraint(item: image, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self.superview, attribute: .width, multiplier: 1.0, constant: 150)
//        image.addConstraints([widthConstraint, heightConstraint])
    }
    
    var dataMessage: ChatModel? {
        didSet {
            if let data = dataMessage {
                time.text = PublicFunction.instance.dateLongToString(dateInMillis: Double(data.createdAt!), pattern: "kk:mm a")
                image.loadUrl(data.message!)
            }
        }
    }
}
