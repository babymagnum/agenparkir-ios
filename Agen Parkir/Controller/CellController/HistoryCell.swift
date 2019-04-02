//
//  HistoryCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 17/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class HistoryCell: UICollectionViewCell {
    
    //MARK: Outlet
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var view2Height: NSLayoutConstraint!
    @IBOutlet weak var topDate: UILabel!
    @IBOutlet weak var view1Height: NSLayoutConstraint!
    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var topDateHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = 5
    }
    
    var dataHistory: HistoryModel? {
        didSet{
            if let data = dataHistory {
                let millis = PublicFunction().dateStringToInt(stringDate: data.trans_date!, pattern: "yyyy-MM-dd kk:mm:ss")
                let time = PublicFunction().dateLongToString(dateInMillis: millis, pattern: "kk:mm a")
                
                self.time.text = time
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowRadius = 2
    }
}
