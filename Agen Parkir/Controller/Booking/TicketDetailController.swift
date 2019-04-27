//
//  TicketDetailController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 21/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import SVProgressHUD
import MidtransKit
import UIKit

class TicketDetailController: BaseViewController, UITextFieldDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var titleTop: UILabel!
    @IBOutlet weak var viewTotalPrice: UIView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var schedule: UILabel!
    @IBOutlet weak var eventPrice: UILabel!
    @IBOutlet weak var ticketLeft: UILabel!
    @IBOutlet weak var totalTicket: UITextField!
    @IBOutlet weak var viewCreditCard: UIView!
    @IBOutlet weak var viewMyCard: UIView!
    @IBOutlet weak var iconCreditCard: UIImageView!
    @IBOutlet weak var textCreditCard: UILabel!
    @IBOutlet weak var iconMyCard: UIImageView!
    @IBOutlet weak var textMyCard: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var viewOrder: UIView!
    @IBOutlet weak var iconOrder: UIImageView!
    @IBOutlet weak var viewContentOrder: UIView!
    
    var ticketModel: TicketModel?
    var mTotalPrice = 0
    var mTicketLeft = 1
    var maxTicket = 0
    var paymentType = 0
    var popRecognizer: InteractivePopRecognizer?
    let operation = OperationQueue()
    var textTotalOrder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInteractiveRecognizer()
        
        customView()
        
        loadItem()
        
        handleGesture()
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        viewCreditCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCreditCardClick)))
        viewMyCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMyCardClick)))
        viewOrder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewOrderClick)))
    }
    
    private func loadItem() {
        if let data = ticketModel {
            self.textTotalOrder = "*Maximum ticket you can buy is \(data.limit_ticket ?? 2)"
            mTotalPrice = data.price!
            mTicketLeft = data.quantity!
            maxTicket = data.limit_ticket!
            titleTop.text = data.building_name!
            if data.images == "" {
                imageHeader.image = UIImage(named: "Artboard 12@0.75x-8")
            } else {
                imageHeader.loadUrl("\(StaticVar.root_images)\(data.images ?? "")")
            }
            totalTicket.placeholder = self.textTotalOrder
            eventName.text = data.name
            eventPrice.text = "Rp \(PublicFunction.instance.prettyRupiah("\(data.price ?? 0)"))"
            ticketLeft.text = "\(data.quantity!)"
            let longSchedule = PublicFunction.instance.dateStringToInt(stringDate: data.schedule!, pattern: "yyyy-MM-dd kk:mm:ss")
            schedule.text = "/ \(PublicFunction.instance.dateLongToString(dateInMillis: longSchedule, pattern: "EEEE dd MMMM yyyy / kk:mm"))"
        }
    }
    
    private func customView() {
        contentMain.layer.borderWidth = 1
        contentMain.layer.borderColor = UIColor.lightGray.cgColor
        contentMain.layer.cornerRadius = 5
        totalTicket.delegate = self
        totalTicket.tag = 1
        PublicFunction.instance.changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
        viewContentOrder.layer.cornerRadius = viewContentOrder.frame.height / 2
        PublicFunction.instance.changeTintColor(imageView: iconOrder, hexCode: 0x00A551, alpha: 1.0)
        viewTotalPrice.layer.cornerRadius = 5
    }
    
    private func gotoTabOngoingController() {
        let tabOngoing = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabOngoingController") as! TabOngoingController
        tabOngoing.fromBooking = true
        tabOngoing.tab = "TicketingController"
        navigationController?.pushViewController(tabOngoing, animated: true)
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
                    PublicFunction.instance.showUnderstandDialog(self, "Error", (error?.localizedDescription)!, "Understand")
                }
            }
        }
    }
    
    private func showDialogSaldoNotEnought() {
        let alert = UIAlertController(title: "My Card", message: "My Card saldo is not enough, your saldo is Rp\(PublicFunction.instance.prettyRupiah(UserDefaults.standard.string(forKey: StaticVar.my_card)!))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Top Up", style: .default, handler: { (action) in
            let topupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopupController") as! TopupController
            self.navigationController?.pushViewController(topupController, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

extension TicketDetailController {
    @objc func viewCreditCardClick() {
        paymentType = 1
        iconCreditCard.image = UIImage(named: "Artboard 136@0.75x-8")
        iconMyCard.image = UIImage(named: "Artboard 129@0.75x-8")
        textCreditCard.textColor = UIColor(rgb: 0x00A551)
        textMyCard.textColor = UIColor.darkGray
    }
    
    @objc func viewMyCardClick() {
        paymentType = 3
        iconMyCard.image = UIImage(named: "Artboard 138@0.75x-8")
        iconCreditCard.image = UIImage(named: "Artboard 127@0.75x-8")
        textMyCard.textColor = UIColor(rgb: 0x00A551)
        textCreditCard.textColor = UIColor.darkGray
    }
    
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func viewOrderClick() {
        if paymentType == 0 {
            PublicFunction.instance.showUnderstandDialog(self, "Choose Payment Type First", "You have to choose payment type before buy the ticket", "Understand")
            return
        }
        
        if totalTicket.text?.trim() == "" || totalTicket.text?.trim() == "0" {
            PublicFunction.instance.showUnderstandDialog(self, "Ticket Empty", "Ticket can't be 0 or empty", "Understand")
            return
        }
        
        switch paymentType {
        case 1:
            SVProgressHUD.show()
            //credit card
            let ticketOrderOperation = TicketOrderOperation((tickets_id: "\(ticketModel?.tickets_id ?? 0)", customers_id: UserDefaults.standard.string(forKey: StaticVar.id)!, quantity_order: (totalTicket.text?.trim())!, payment_types_id: "\(paymentType)"))
            operation.addOperation(ticketOrderOperation)
            ticketOrderOperation.completionBlock = {
                DispatchQueue.main.async {
                    switch ticketOrderOperation.state{
                    case .success?:
                        self.showPaymentController(ticketOrderOperation.token!)
                    case .error?:
                        PublicFunction.instance.showUnderstandDialog(self, "Error", ticketOrderOperation.error!, "Understand")
                    default:
                        PublicFunction.instance.showUnderstandDialog(self, "Error", "There was something error with system, please try again", "Understand")
                    }
                }
            }
        default:
            //saldo is not enough
            if Int(UserDefaults.standard.string(forKey: StaticVar.my_card)!)! < self.mTotalPrice * Int((totalTicket.text?.trim())!)! {
                self.showDialogSaldoNotEnought()
                return
            }
            
            let ticketOrderOperation = TicketOrderOperation((tickets_id: "\(ticketModel?.tickets_id ?? 0)", customers_id: UserDefaults.standard.string(forKey: StaticVar.id)!, quantity_order: (totalTicket.text?.trim())!, payment_types_id: "\(paymentType)"))
            operation.addOperation(ticketOrderOperation)
            ticketOrderOperation.completionBlock = {
                DispatchQueue.main.async {
                    switch ticketOrderOperation.state{
                    case .success?:
                        //payment success
                        self.gotoTabOngoingController()
                    case .error?:
                        PublicFunction.instance.showUnderstandDialog(self, "Error", ticketOrderOperation.error!, "Understand")
                    default:
                        PublicFunction.instance.showUnderstandDialog(self, "Error", "There was something error with system, please try again", "Understand")
                    }
                }
            }
        }
    }
}

extension TicketDetailController: MidtransUIPaymentViewControllerDelegate {
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, save result: MidtransMaskedCreditCard!) {
        print("save card success")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, saveCardFailed error: Error!) {
        print("save card failed")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentPending result: MidtransTransactionResult!) {
        PublicFunction.instance.showUnderstandDialog(self, "Payment Pending", "Your payment is pending, please wait before we make sure that your payment in success", "Understand")
        print("payment success \(result.debugDescription)")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentSuccess result: MidtransTransactionResult!) {
        gotoTabOngoingController()
        print("payment success \(result.debugDescription)")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentFailed error: Error!) {
        PublicFunction.instance.showUnderstandDialog(self, "Payment Failed", error.localizedDescription, "Understand")
        print("payment failed error: \(error.localizedDescription)")
    }
    
    func paymentViewController_paymentCanceled(_ viewController: MidtransUIPaymentViewController!) {
        print("payment canceled")
    }
    
    
}

extension TicketDetailController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            if Int((totalTicket.text?.trim())!)! > 5 {
                self.totalTicket.text = ""
                PublicFunction.instance.showUnderstandDialog(self, "Max Ticket Order", self.textTotalOrder, "Understand")
                return
            }
            
            totalPrice.text = "Rp. \(PublicFunction.instance.prettyRupiah("\(mTotalPrice * Int((totalTicket.text?.trim())!)!)"))"
            ticketLeft.text = "\(self.mTicketLeft - Int((totalTicket.text?.trim())!)!)"
        }
    }
}
