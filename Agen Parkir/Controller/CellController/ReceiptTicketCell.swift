//
//  ReceiptTicketCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 22/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

protocol ReceiptTicketProtocol {
    func contentMain(_ ticketModel: TicketDetailModel)
}

class ReceiptTicketCell: UICollectionViewCell {
    //MARK: Outlet
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var dividerHeight: NSLayoutConstraint!
    @IBOutlet weak var totalTicket: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var controller: UIViewController?
    var delegate: ReceiptTicketProtocol?
    var operation = OperationQueue()
    var ticketDetail: TicketDetailModel?
    
    var orders_id: String? {
        didSet {
            if let order = orders_id {
                self.loadDetail(order)
            }
        }
    }
    
    private func loadDetail(_ orders_id: String) {
        let ticketDetailOperation = TicketDetailOperation(orders_id)
        operation.addOperation(ticketDetailOperation)
        ticketDetailOperation.completionBlock = {
            DispatchQueue.main.async {
                switch ticketDetailOperation.state {
                case .success?:
                    self.ticketDetail = ticketDetailOperation.ticketDetail
                    self.updateUI(ticketDetailOperation.ticketDetail!)
                case .error?:
                    print("Error")
                default:
                    print("Error")
                }
            }
        }
    }
    
    private func updateUI(_ data: TicketDetailModel) {
        let doubleSchedule = PublicFunction().dateStringToInt(stringDate: data.schedule!, pattern: "yyyy-MM-dd kk:mm:ss")
        eventName.text = data.tickets_name
        date.text = PublicFunction().dateLongToString(dateInMillis: doubleSchedule, pattern: "EEEE, dd MMMM yyyy / kk:mm")
        venueName.text = data.building_name
        totalTicket.text = "\(data.quantity_order ?? 0) Ticket"
    }
    
    override func awakeFromNib() {
        contentMain.layer.cornerRadius = 5
        
        handleGesture()
        
        iconHeight.constant = venueName.frame.height + eventName.frame.height + date.frame.height + 18
        iconWidth.constant = venueName.frame.height + eventName.frame.height + date.frame.height + 18
        dividerHeight.constant = venueName.frame.height + eventName.frame.height + date.frame.height + 18
    }
    
    private func handleGesture() {
        contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentMainClick)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.6
    }
}

extension ReceiptTicketCell {
    @objc func contentMainClick() {
        if let ticket = ticketDetail {
            delegate?.contentMain(ticket)
        } else {
            PublicFunction().showUnderstandDialog(controller!, "Data Still Loading", "Data is loading...", "Understand")
        }
    }
}
