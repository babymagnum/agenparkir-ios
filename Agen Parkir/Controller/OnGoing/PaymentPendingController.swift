//
//  PaymentPendingController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 27/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import XLPagerTabStrip

class PaymentPendingController: BaseViewController, IndicatorInfoProvider, BaseViewControllerProtocol, UICollectionViewDelegate {
    
    // MARK : Outlet
    @IBOutlet weak var emptyText: UILabel!
    @IBOutlet weak var paymentPendingCollectionView: UICollectionView!
    
    // MARK: Props
    private var listPaymentPending = [PaymentPendingModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        
        loadPaymentPending()
        
        handleGesture()
    }
    
    private func handleGesture() {
        emptyText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyTextClick)))
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Payment")
    }
    
    private func loadPaymentPending(){
        SVProgressHUD.show()
        
        let operation = OperationQueue()
        let paymentPendingOperation = PaymentPendingOperation()
        operation.addOperation(paymentPendingOperation)
        
        paymentPendingOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch paymentPendingOperation.state{
                case .success?:
                    self.emptyText.isHidden = true
                    self.listPaymentPending = paymentPendingOperation.listPaymentPending
                    self.paymentPendingCollectionView.reloadData()
                case .error?:
                    PublicFunction.instance.showUnderstandDialog(self, "Empty", "You have no payment pending yet", "Understand")
                    self.emptyText.isHidden = false
                case .empty?:
                    PublicFunction.instance.showUnderstandDialog(self, "Empty", "You have no payment pending yet", "Understand")
                    self.emptyText.isHidden = false
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", "Ooops, operation is failed due to system error", "Understand")
                }
            }
        }
    }
    
    private func initCollectionView(){
        paymentPendingCollectionView.delegate = self
        paymentPendingCollectionView.dataSource = self
        
        let layout = paymentPendingCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cell = paymentPendingCollectionView.dequeueReusableCell(withReuseIdentifier: "PaymentPendingCell", for: IndexPath(item: 0, section: 0)) as! PaymentPendingCell
        let height = cell.bankName.frame.height + cell.total.frame.height + cell.containerVirtualAccount.frame.height + 30
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: height)
    }
}

extension PaymentPendingController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPaymentPending.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentPendingCell", for: indexPath) as! PaymentPendingCell
        cell.paymentPendingData = listPaymentPending[indexPath.row]
        cell.buttonCopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonCopyClick(sender:))))
        return cell
    }
}

// MARK: Handle gesture
extension PaymentPendingController{
    @objc func buttonCopyClick(sender: UITapGestureRecognizer) {
        if let indexpath = paymentPendingCollectionView.indexPathForItem(at: sender.location(in: paymentPendingCollectionView)) {
            
            //copy virtual account here
            
        }
    }
    
    @objc func emptyTextClick() {
        loadPaymentPending()
    }
}

// MARK: Base view controller delegate
extension PaymentPendingController{
    func noInternet() {
        emptyText.text = "No internet connection, tap to reload"
    }
    
    func hasInternet() {
        emptyText.text = "You have no payment pending yet..."
    }
}
