//
//  TicketDetailReceiptController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 22/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class TicketDetailReceiptController: BaseViewController {
    
    //MARK: Outlet
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var viewReedemDate: UIView!
    @IBOutlet weak var titleTop: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var bookingCode: UILabel!
    @IBOutlet weak var imageBarcode: UIImageView!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var schedule: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var totalTicket: UILabel!
    @IBOutlet weak var paymentType: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var viewAccount: UIView!
    @IBOutlet weak var viewBookingCode: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var reedemDate: UILabel!
    
    var ticketModel: TicketDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customView()
        
        loadData()
        
        handleGesture()
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func customView() {
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x000000, alpha: 0.8)
        viewAccount.layer.cornerRadius = 4
        viewAccount.layer.borderWidth = 1
        viewAccount.layer.borderColor = UIColor.lightGray.cgColor
        
        viewBookingCode.layer.cornerRadius = 4
        viewBookingCode.layer.borderWidth = 1
        viewBookingCode.layer.borderColor = UIColor.lightGray.cgColor
        
        viewContent.layer.cornerRadius = 4
        viewContent.layer.borderWidth = 1
        viewContent.layer.borderColor = UIColor.lightGray.cgColor
        
        viewReedemDate.layer.cornerRadius = 4
        viewReedemDate.layer.borderWidth = 1
        viewReedemDate.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func loadData() {
        if let data = ticketModel {
            if data.images == "" {
                imageHeader.image = UIImage(named: "Artboard 12@0.75x-8")
            } else {
                imageHeader.loadUrl("\(StaticVar.root_images)\(data.images ?? "")")
            }
            let doubleSchedule = PublicFunction().dateStringToInt(stringDate: data.schedule!, pattern: "yyyy-MM-dd kk:mm:ss")
            let doubleReedemDate = PublicFunction().dateStringToInt(stringDate: data.reedem_date!, pattern: "yyyy-MM-dd kk:mm:ss")
            reedemDate.text = "/ \(PublicFunction().dateLongToString(dateInMillis: doubleReedemDate, pattern: "EEEE dd MMMM yyyy / kk:mm")) WIB"
            customerName.text = data.customers_name
            bookingCode.text = data.booking_code
            schedule.text = "/ \(PublicFunction().dateLongToString(dateInMillis: doubleSchedule, pattern: "EEEE dd MMMM yyyy / kk:mm")) WIB"
            eventName.text = data.tickets_name
            venueName.text = "[ \(data.building_name ?? "") ]"
            totalTicket.text = "\(data.quantity_order ?? 0)"
            switch data.types_pays_id {
            case 1:
                paymentType.text = "Credit Card"
            default:
                paymentType.text = "My Card"
            }
            totalPrice.text = "Rp \(PublicFunction().prettyRupiah("\(data.booking_total ?? 0)"))"
            imageBarcode.image = Barcode.fromString(string: data.booking_code!)
        }
    }
    
}

extension TicketDetailReceiptController {
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
}
