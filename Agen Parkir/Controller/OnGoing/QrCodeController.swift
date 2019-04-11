//
//  QrCodeController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 13/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class QrCodeController: BaseViewController {
    
    //MARK: Outlet
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var plateNumber: UILabel!
    @IBOutlet weak var bookingOrder: UILabel!
    @IBOutlet weak var viewIconClose: UIView!
    @IBOutlet weak var iconClose: UIImageView!
    @IBOutlet weak var qrCodeImageWidth: NSLayoutConstraint!
    @IBOutlet weak var qrCodeImageHeight: NSLayoutConstraint!
    @IBOutlet weak var contentMain: UIView!
    
    //MARK: Props
    var bookingData: (booking_code: String, customer_name: String, plate_number: String)?
    var delegate: UpdateOngoingProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customView()
        
        handleGesture()
        
        loadQRCode()
    }
    
    private func loadQRCode() {
        guard let booking = bookingData else { return }
        
        qrCodeImage.image = PublicFunction().createQRFromString(booking.booking_code, size: qrCodeImage.frame.size)
        username.text = booking.customer_name.uppercased()
        bookingOrder.text = booking.booking_code
        plateNumber.text = "[ \(booking.plate_number) ]"
    }
    
    private func handleGesture() {
        viewIconClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewIconCloseClick)))
    }
    
    private func customView(){
        contentMain.layer.borderWidth = 1
        contentMain.layer.borderColor = UIColor.lightGray.cgColor
        contentMain.layer.cornerRadius = 4
        qrCodeImageWidth.constant = UIScreen.main.bounds.width - 80
        qrCodeImageHeight.constant = UIScreen.main.bounds.width - 80
        PublicFunction().changeTintColor(imageView: iconClose, hexCode: 0xD50000, alpha: 1.0)
        viewIconClose.layer.cornerRadius = viewIconClose.frame.width / 2
        viewIconClose.layer.shadowColor = UIColor.lightGray.cgColor
        viewIconClose.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        viewIconClose.layer.shadowRadius = 3
        viewIconClose.layer.shadowOpacity = 1.0
    }
}

extension QrCodeController {
    @objc func viewIconCloseClick() {
        delegate?.updateData()
        dismiss(animated: true, completion: nil)
    }
}
