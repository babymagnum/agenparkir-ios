//
//  PaymentPendingCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 27/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class PaymentPendingCell: UICollectionViewCell {
    
    @IBOutlet weak var viewDividerHeight: NSLayoutConstraint!
    @IBOutlet weak var iconMainHeight: NSLayoutConstraint!
    @IBOutlet weak var iconMainWidth: NSLayoutConstraint!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var virtualAccount: UILabel!
    @IBOutlet weak var buttonCopy: UIButton!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var containerVirtualAccount: UIView!
    
    var paymentPendingData: PaymentPendingModel? {
        didSet{
            if let data = paymentPendingData {
                self.bankName.text = "Bank \(data.bank_name?.capitalizingFirstLetter() ?? "")"
                self.total.text = "Rp \(PublicFunction.instance.prettyRupiah(data.total!))"
                self.virtualAccount.text = data.virtual_account
                self.dueDate.text = data.expired_time
            }
        }
    }
    
    override func awakeFromNib() {
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = 5
        
        buttonCopy.layer.cornerRadius = 5
        
        let height = bankName.frame.height + dueDate.frame.height + containerVirtualAccount.frame.height
        iconMainHeight.constant = height
        iconMainWidth.constant = height
        viewDividerHeight.constant = height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6
    }
}
