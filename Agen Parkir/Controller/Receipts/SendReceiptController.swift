//
//  SendReceiptController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 15/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class SendReceiptController: BaseViewController {
    
    //MARK: Outlet
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var customerImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var parkingDone: UILabel!
    @IBOutlet weak var areaParkingLot: UILabel!
    @IBOutlet weak var plateNumber: UILabel!
    @IBOutlet weak var bookingOrderId: UILabel!
    @IBOutlet weak var parkType: UIButton!
    @IBOutlet weak var vehicleType: UIButton!
    @IBOutlet weak var payment: UIButton!
    @IBOutlet weak var parkingRent: UIButton!
    @IBOutlet weak var voucher: UIButton!
    @IBOutlet weak var total: UIButton!
    @IBOutlet weak var buttonSendReceipt: UIButton!
    @IBOutlet weak var iconBack: UIImageView!
    
    //MARK: Props
    var receiptsModel: ReceiptsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("order id receipt \(receiptsModel?.orders_id ?? 0)")

        customView()
        
        loadData()
        
        handleGesture()
    }
    
    private func handleGesture() {
        buttonSendReceipt.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonSendReceiptClick)))
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func loadData() {
        if let data = receiptsModel{
            customerImage.loadUrl("\(StaticVar.root_images)\(data.customers_images!)")
            name.text = data.customers_name
            areaParkingLot.text = "\(data.building_name ?? "") [ \(data.parking_lot ?? "") ]"
            plateNumber.text = "[ \(data.plate_number ?? "") ]"
            bookingOrderId.text = "Booking Order No: \(data.booking_code ?? "")"
            parkType.setTitle(data.parking_types == 0 ? "Standard" : "Valet", for: .normal)
            vehicleType.setTitle(data.vehicle_types == 1 ? "Motors" : "Cars", for: .normal)
            switch data.payment_types {
                case 1: payment.setTitle("Credit/Debit", for: .normal)
                case 2: payment.setTitle("Cash", for: .normal)
                default: payment.setTitle("My Card", for: .normal)
            }
            parkingRent.setTitle("Rp\(PublicFunction().prettyRupiah("\(data.booking_sub_total ?? 1)"))", for: .normal)
            total.setTitle("Rp\(PublicFunction().prettyRupiah("\(data.booking_total ?? 1)"))", for: .normal)
            voucher.setTitle("Rp\(PublicFunction().prettyRupiah("\(data.vouchers_nominal ?? 1)"))", for: .normal)
            
            if data.booking_start_time != "" {
                let dateInMillis = PublicFunction().dateStringToInt(stringDate: data.booking_start_time!, pattern: "yyyy-MM-dd kk:mm:ss")
                let stringDate = PublicFunction().dateLongToString(dateInMillis: dateInMillis, pattern: "dd MMMM yyyy, kk:mm a")
                self.parkingDone.text = "\(stringDate)"
            } else {
                self.parkingDone.text = "Unknowns date"
            }
        }
    }
    
    private func customView() {
        contentMain.layer.cornerRadius = 7
        customerImage.clipsToBounds = true
        customerImage.layer.cornerRadius = customerImage.frame.width / 2
        buttonSendReceipt.layer.cornerRadius = buttonSendReceipt.frame.height / 2
    }
}

extension SendReceiptController {
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func buttonSendReceiptClick() {
        if let data = receiptsModel {
            SVProgressHUD.show()
            
            let operation = OperationQueue()
            let submitReceipts = SubmitReceipts(order_id: data.orders_id!)
            operation.addOperations([submitReceipts], waitUntilFinished: false)
            submitReceipts.completionBlock = {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    switch submitReceipts.state{
                    case .success?:
                        let alert = UIAlertController(title: "Success", message: "Thank you \(data.customers_name ?? "") for using our services", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true)
                    case .error?:
                        PublicFunction().showUnderstandDialog(self, "Error Submiting", submitReceipts.error!, "Understand")
                    default:
                        PublicFunction().showUnderstandDialog(self, "Error Submiting", "There was some error with system, try to tap the send button again", "Understand")
                    }
                }
            }
        }
    }
}
