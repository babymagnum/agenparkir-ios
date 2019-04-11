//
//  BookingAgreementController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 11/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import MidtransKit

class BookingAgreementController: BaseViewController {
    
    //MARK: Outlet
    @IBOutlet weak var plateNumber: UILabel!
    @IBOutlet weak var textTotal: UILabel!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var iconCancel: UIImageView!
    @IBOutlet weak var viewImageHeader: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var bookingOrder: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var bookingSlot: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var discon: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var viewAgree: UIView!
    @IBOutlet weak var viewCancel: UIView!
    @IBOutlet weak var viewCars: UIView!
    @IBOutlet weak var viewMotorcycle: UIView!
    @IBOutlet weak var viewValet: UIView!
    @IBOutlet weak var viewStandart: UIView!
    @IBOutlet weak var viewIndoor: UIView!
    @IBOutlet weak var viewOutdoor: UIView!
    @IBOutlet weak var viewCredit: UIView!
    @IBOutlet weak var viewCash: UIView!
    @IBOutlet weak var viewMycard: UIView!
    
    //MARK: Props
    var dataBooking: (vehicleType: Int, parkingType: Int, placeType: String, paymentType: Int)?
    var returnBookingData: (order_id: Int, booking_code: String, parking_lot: Int, area_name: String, customer_name: String, building_name: String, is_percentage: Int, plate_number: String, sub_tariff: Int, total: Int)?
    let operation = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        customView()
        
        populateData()
        
        handleGesture()
    }
    
    private func handleGesture() {
        viewCancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCancelClick)))
        viewAgree.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewAgreeClick)))
        
    }
    
    private func populateData() {
        imageHeader.loadUrl("\(StaticVar.root_images)\(UserDefaults.standard.string(forKey: StaticVar.images)!)")
        
        if let data = dataBooking {
            if data.vehicleType == 1 {
                self.viewCars.isHidden = true
            } else {
                self.viewMotorcycle.isHidden = true
            }
            
            if data.parkingType == 0 {
                self.viewValet.isHidden = true
            } else {
                self.viewStandart.isHidden = true
            }
            
            if data.placeType == "0" {
                self.viewOutdoor.isHidden = true
            } else {
                self.viewIndoor.isHidden = true
            }
            
            switch data.paymentType{
            case 1:
                self.viewCash.isHidden = true
                self.viewMycard.isHidden = true
            case 2:
                self.viewCredit.isHidden = true
                self.viewMycard.isHidden = true
            default:
                self.viewCredit.isHidden = true
                self.viewCash.isHidden = true
            }
        }
        
        if let returnBooking = self.returnBookingData {
            self.username.text = returnBooking.customer_name
            self.venueName.text = returnBooking.building_name
            self.bookingSlot.text = "\(returnBooking.parking_lot) - \(returnBooking.area_name)"
            self.plateNumber.text = "[ \(returnBooking.plate_number) ]"
            
            //custom price text
            self.priceText(PublicFunction().prettyRupiah("\(returnBooking.sub_tariff)"), 0x00A551, self.price)
            self.priceText(PublicFunction().prettyRupiah("\(returnBooking.total)"), 0x000000, self.totalPrice)
        }
    }
    
    private func priceText(_ content: String, _ color: Int, _ label: UILabel) {
        let mainString = "Rp. \(content),-"
        let editedText = "Rp. "
        let editedString = NSMutableAttributedString(string: mainString)
        editedString.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0)], range: (mainString as NSString).range(of: editedText))
        label.attributedText = editedString
        label.textColor = UIColor(rgb: color)
    }
    
    private func customView() {
        imageHeader.clipsToBounds = true
        imageHeader.layer.cornerRadius = imageHeader.frame.width / 2
        PublicFunction().changeTintColor(imageView: iconCancel, hexCode: 0xd50000, alpha: 1.0)
        viewImageHeader.layer.cornerRadius = viewImageHeader.frame.width / 2
        viewImageHeader.layer.borderWidth = 1
        viewImageHeader.layer.borderColor = UIColor(rgb: 0x00A551).cgColor
        viewAgree.clipsToBounds = false
        viewAgree.layer.cornerRadius = 20
        viewAgree.layer.shadowColor = UIColor.lightGray.cgColor
        viewAgree.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        viewAgree.layer.shadowRadius = 3
        viewAgree.layer.shadowOpacity = 1.0
        viewCancel.clipsToBounds = false
        viewCancel.layer.cornerRadius = viewCancel.frame.width / 2
        viewCancel.layer.shadowColor = UIColor.lightGray.cgColor
        viewCancel.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        viewCancel.layer.shadowRadius = 3
        viewCancel.layer.shadowOpacity = 1.0
    }
    
    private func showPaymentController(_ token: String){
        DispatchQueue.main.async {
            MidtransMerchantClient.shared().requestTransacation(withCurrentToken: token) { (response, error) in
                SVProgressHUD.dismiss()
                
                if let response = response {
                    let paymentController = MidtransUIPaymentViewController.init(token: response, andPaymentFeature: .MidtransPaymentFeatureCreditCard)
                    paymentController?.paymentDelegate = self
                    self.present(paymentController!, animated: true, completion: nil)
                } else {
                    PublicFunction().showUnderstandDialog(self, "Error", (error?.localizedDescription)!, "Understand")
                }
            }
        }
    }
    
    private func goToOngoingController(){
        let tabOngoingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabOngoingController") as! TabOngoingController
        tabOngoingController.fromBooking = true
        tabOngoingController.vehicleType = self.dataBooking?.vehicleType
        tabOngoingController.tab = "ParkingController"
        self.navigationController?.pushViewController(tabOngoingController, animated: true)
    }
}

extension BookingAgreementController: MidtransUIPaymentViewControllerDelegate {
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, save result: MidtransMaskedCreditCard!) {
        print("success save card")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, saveCardFailed error: Error!) {
        print("failed save card")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentPending result: MidtransTransactionResult!) {
        PublicFunction().showUnderstandDialog(self, "Payment Pending", "Your payment is pending", "Understand")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentSuccess result: MidtransTransactionResult!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.goToOngoingController()
        }
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentFailed error: Error!) {
        PublicFunction().showUnderstandDialog(self, "Payment Error", error.localizedDescription, "Understand")
    }
    
    func paymentViewController_paymentCanceled(_ viewController: MidtransUIPaymentViewController!) {
        print("payment canceled")
    }
}

extension BookingAgreementController {
    
    @objc func viewAgreeClick() {
        switch dataBooking?.paymentType {
        case 2, 3:
            //check my card saldo
            if dataBooking?.paymentType == 3 && Int(UserDefaults.standard.string(forKey: StaticVar.my_card)!)! < (returnBookingData?.total)! {
                let alert = UIAlertController(title: "My Card", message: "Your my card saldo is not enough \(UserDefaults.standard.string(forKey: StaticVar.my_card) ?? "")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Top Up", style: .default, handler: { (action) in
                    let topupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopupController") as! TopupController
                    self.navigationController?.pushViewController(topupController, animated: true)
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true)
                return
            }
            
            SVProgressHUD.show()
            
            if let booking = returnBookingData {
                let orderOperation = OrderOperation(order_id: "\(booking.order_id)")
                operation.addOperation(orderOperation)
                orderOperation.completionBlock = {
                    SVProgressHUD.dismiss()
                    
                    switch orderOperation.state {
                    case .success?:
                        DispatchQueue.main.async {
                            self.goToOngoingController()
                        }
                    case .error?:
                        PublicFunction().showUnderstandDialog(self, "Error", orderOperation.error!, "Understand")
                    default:
                        PublicFunction().showUnderstandDialog(self, "Error", "There was something error with system, please try again", "Understand")
                    }
                }
            }
        default:
            SVProgressHUD.show()
            
            let creditCardOperation = TopupCreditCardOperation(topupData: (order_type: "parking", order_id: (returnBookingData?.order_id)!, gross_amount: (returnBookingData?.total)!, customers_id: Int(UserDefaults.standard.string(forKey: StaticVar.id)!)!))
            
            operation.addOperation(creditCardOperation)
            
            creditCardOperation.completionBlock = {
                switch creditCardOperation.state {
                case .success?:
                    self.showPaymentController(creditCardOperation.token!)
                case .error?:
                    SVProgressHUD.dismiss()
                    PublicFunction().showUnderstandDialog(self, "Error", creditCardOperation.error!, "Understand")
                default:
                    SVProgressHUD.dismiss()
                    PublicFunction().showUnderstandDialog(self, "Error", "There was something error with system, please try again", "Understand")
                }
            }
        }
    }
    
    @objc func viewCancelClick() {
        SVProgressHUD.show()
        
        if let booking = returnBookingData {
            let cancelBookingOperation = CancelBookingOperation(orders_id: "\(booking.order_id)")
            operation.addOperation(cancelBookingOperation)
            cancelBookingOperation.completionBlock = {
                SVProgressHUD.dismiss()
                
                switch cancelBookingOperation.state {
                case .success?:
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .error?:
                    PublicFunction().showUnderstandDialog(self, "Error", cancelBookingOperation.error!, "Understand")
                default:
                    PublicFunction().showUnderstandDialog(self, "Error", "There was something error with system, please try again later", "Understand")
                }
            }
        }
    }
}
