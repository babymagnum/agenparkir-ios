//
//  TopupController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 16/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import MidtransKit
import SVProgressHUD
import RxSwift
import RxCocoa

class TopupController: BaseViewController {
    //MARK: Outlet
    @IBOutlet weak var inputAmount: UITextField!
    @IBOutlet weak var buttonProceed: UIButton!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var saldoMyCard: UILabel!
    
    //MARK: Props
    let operation = OperationQueue()
    var default_param_rx = BehaviorRelay(value: false)
    let bag = DisposeBag()
    var formState: FormState?
    var delegate: UpdateCurrentDataProtocol?
    let operationQueue = OperationQueue()
    var totalAmount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        handleGesture()
        
        customView()
        
        currentUpdate()
        
        bindUI()
    }
    
    private func bindUI() {
        Observable.combineLatest(inputAmount.rx.text, default_param_rx.asObservable(), resultSelector: {
            amount, default_param in
            
            if (amount?.count)! > 0 {
                self.formState = .allow
                self.totalAmount = PublicFunction.instance.prettyRupiah((amount?.trim().replacingOccurrences(of: "Rp", with: "").replacingOccurrences(of: ".", with: ""))!)
                print(self.totalAmount)
            } else {
                self.formState = .dont
            }
            
        }).subscribe().disposed(by: bag)
    }
    
    private func customView() {
        inputAmount.tag = 1
        inputAmount.delegate = self
        buttonProceed.clipsToBounds = true
        buttonProceed.layer.cornerRadius = 5
        PublicFunction.instance.changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
    }
    
    private func handleGesture() {
        iconBack.isUserInteractionEnabled = true
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        buttonProceed.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonProceedClick)))
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureBack))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
}

extension TopupController {
    @objc func swipeGestureBack() {
        delegate?.updateData()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func iconBackClick() {
        delegate?.updateData()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func buttonProceedClick() {
        if formState == .dont {
            PublicFunction.instance.showUnderstandDialog(self, "Empty Amount", "Please input the amount price you want to topup before tap proceed button", "Understand")
            return
        }
        
        let amount = inputAmount.text?.trim().replacingOccurrences(of: "Rp", with: "").replacingOccurrences(of: ".", with: "")
//        if Int(amount!)! < 50000 {
//            PublicFunction.instance.showUnderstandDialog(self, "Top Up Amount", "Minimal top up amount is Rp 50.000", "Understand")
//            return
//        }
        
        inputAmount.resignFirstResponder()
        
        SVProgressHUD.show()
        
        let topupOperation = TopupOperation(Int(amount!)!)
        operation.addOperation(topupOperation)
        topupOperation.completionBlock = {
            
            switch topupOperation.state {
            case .success?:
                DispatchQueue.main.async {
                    self.topupCreditCard(topupOperation.orders_id!, Int(amount!)!)
                    self.inputAmount.text = ""
                }
            case .error?:
                SVProgressHUD.dismiss()
                PublicFunction.instance.showUnderstandDialog(self, "Error Generate Token", topupOperation.error!, "Understand")
            default:
                SVProgressHUD.dismiss()
                PublicFunction.instance.showUnderstandDialog(self, "Error Generate Token", "There was some error in the system, please try again", "Understand")
            }
        }
    }
    
    private func topupCreditCard(_ orders_id: Int, _ amount: Int) {
        let topupCreditCardOperation = TopupCreditCardOperation(topupData: (order_type: "topup", order_id: orders_id, gross_amount: amount, customers_id: Int(UserDefaults.standard.string(forKey: StaticVar.id)!)!))
        
        self.operation.addOperation(topupCreditCardOperation)
        
        topupCreditCardOperation.completionBlock = {
            
            switch topupCreditCardOperation.state {
            case .success?:
                print("success generating token \(topupCreditCardOperation.token!)")
                self.openPaymentController(topupCreditCardOperation.token!)
            case .error?:
                SVProgressHUD.dismiss()
                PublicFunction.instance.showUnderstandDialog(self, "Error Generating Token", topupCreditCardOperation.error!, "Understand")
            default:
                SVProgressHUD.dismiss()
                PublicFunction.instance.showUnderstandDialog(self, "Error Generating Token", "There was some error with the system, please try again", "Understand")
            }
        }
    }
    
    private func openPaymentController(_ token: String) {
        DispatchQueue.main.async {
            MidtransMerchantClient.shared().requestTransacation(withCurrentToken: token) { (response, error) in
                SVProgressHUD.dismiss()
                
                if let response = response {
                    let paymentController = MidtransUIPaymentViewController.init(token: response)
                    paymentController?.paymentDelegate = self
                    self.present(paymentController!, animated: true, completion: nil)
                } else {
                    PublicFunction.instance.showUnderstandDialog(self, "Error", (error?.localizedDescription)!, "Understand")
                }
            }
        }
    }
    
    private func currentUpdate() {
        SVProgressHUD.show()
        
        let currentOperation = CurrentOperation()
        operationQueue.addOperation(currentOperation)
        
        currentOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            DispatchQueue.main.async {
                switch currentOperation.state {
                case .success?:
                    self.updateUI(currentOperation.currentModel!)
                case .error?:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", currentOperation.error!, "Understand")
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", "There was something with system, try to reload data", "Reload", completionHandler: {
                        self.currentUpdate()
                    })
                }
            }
            
        }
    }
    
    private func updateUI(_ model: CurrentModel){
        self.saldoMyCard.text = model.getMyCard()
    }
}

extension TopupController:  MidtransUIPaymentViewControllerDelegate {
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, save result: MidtransMaskedCreditCard!) {
        print("save result")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, saveCardFailed error: Error!) {
        print("save card failed")
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentPending result: MidtransTransactionResult!) {
        PublicFunction.instance.showUnderstandDialog(self, "Payment Pending", result.debugDescription, "Understand")
        self.currentUpdate()
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentSuccess result: MidtransTransactionResult!) {
        PublicFunction.instance.showUnderstandDialog(self, "Payment Success", result.debugDescription, "Understand")
        self.currentUpdate()
    }
    
    func paymentViewController(_ viewController: MidtransUIPaymentViewController!, paymentFailed error: Error!) {
        PublicFunction.instance.showUnderstandDialog(self, "Payment Failed", error.localizedDescription, "Understand")
    }
    
    func paymentViewController_paymentCanceled(_ viewController: MidtransUIPaymentViewController!) {
        self.currentUpdate()
    }
}

extension TopupController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            self.inputAmount.text? = ""
            self.inputAmount.text = "Rp\(self.totalAmount)"
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            if self.inputAmount.text?.trim() == "" {
                return
            }
            
            self.inputAmount.text? = ""
            self.inputAmount.text = "Rp\(self.totalAmount)"
        }
    }
}
