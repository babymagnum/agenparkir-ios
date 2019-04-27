//
//  MyChatCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 30/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class MyChatCell: UICollectionViewCell {
    
    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var message: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var messageWidth: NSLayoutConstraint!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        message.clipsToBounds = true
        message.layer.cornerRadius = 7
        message.titleLabel?.numberOfLines = 0
        message.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    var dataMessage: ChatModel? {
        didSet {
            if let data = dataMessage {
                time.text = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: data.createdAt!)!, pattern: "kk:mm a")
                message.setTitle(data.message, for: .normal)
                
                let messageContent = data.message
                let approximateTextWidth = UIScreen.main.bounds.width - 65 - time.frame.width
                let size = CGSize(width: approximateTextWidth, height: 1000)
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
                let estimatedFrame = NSString(string: messageContent!).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                messageWidth.constant = approximateTextWidth
                messageHeight.constant = estimatedFrame.height + 14
            }
        }
    }
}
