//
//  ReceiptsController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 14/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class ReceiptsController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var iconClearAll: UIImageView!
    @IBOutlet weak var viewClearAll: UIView!
    @IBOutlet weak var receiptsCollectionView: UICollectionView!
    @IBOutlet weak var emptyReceipts: UILabel!
    @IBOutlet weak var iconBack: UIImageView!
    
    var listReceipts = [ReceiptsModel]()
    var currentPage = 1
    var popRecognizer: InteractivePopRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()

        initCollectionView()
        
        customView()
        
        loadReceipts()
        
        handleGesture()
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func loadReceipts() {
        SVProgressHUD.show()
        
        let operation = OperationQueue()
        let listReceiptsOperation = ListReceiptsOperation(currentPage: currentPage)
        operation.addOperations([listReceiptsOperation], waitUntilFinished: false)
        listReceiptsOperation.completionBlock = {
            //update the ui in main thread
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                self.receiptsCollectionView.isScrollEnabled = true
                
                switch listReceiptsOperation.state {
                case .success?:
                    self.currentPage += 1
                    for (index, receipt) in listReceiptsOperation.listReceipts.enumerated() {
                        self.listReceipts.append(receipt)
                        
                        if index == listReceiptsOperation.listReceipts.count - 1{
                            self.receiptsCollectionView.reloadData()
                        }
                    }
                case .empty?:
                    if self.listReceipts.count == 0 {
                        self.emptyReceipts.isHidden = false
                        PublicFunction().showUnderstandDialog(self, "Empty Receipts", "You haven't make any order yet", "Understand")
                    } else {
                        PublicFunction().showUnderstandDialog(self, "End Of List", "You have reach the end of list", "Understand")
                    }
                case .error?:
                    self.emptyReceipts.isHidden = false
                    PublicFunction().showUnderstandDialog(self, "Error", listReceiptsOperation.error!, "Understand")
                default:
                    self.emptyReceipts.isHidden = false
                    PublicFunction().showUnderstandDialog(self, "Error", "There was something error with system, please refresh the page", "Understand")
                }
            }
        }
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func initCollectionView() {
        receiptsCollectionView.delegate = self
        receiptsCollectionView.dataSource = self
        
        let cell = receiptsCollectionView.dequeueReusableCell(withReuseIdentifier: "ReceiptsCell", for: IndexPath(item: 0, section: 0)) as! ReceiptsCell
        let layout = receiptsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let height = 30 + cell.venueName.frame.height + cell.message.frame.height + cell.orderDate.frame.height
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: height)
    }
    
    private func customView() {
        viewClearAll.layer.cornerRadius = viewClearAll.frame.height / 2
        viewClearAll.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        PublicFunction().changeTintColor(imageView: iconClearAll, hexCode: 0xffffff, alpha: 1.0)
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
    }
}

extension ReceiptsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listReceipts.count - 1 {
            self.receiptsCollectionView.isScrollEnabled = false
            self.loadReceipts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listReceipts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReceiptsCell", for: indexPath) as! ReceiptsCell
        cell.receiptsData = listReceipts[indexPath.item]
        cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(receiptContentClick(sender:))))
        return cell
    }
}

extension ReceiptsController{
    @objc func receiptContentClick(sender: UITapGestureRecognizer) {
        if let indexpath = receiptsCollectionView.indexPathForItem(at: sender.location(in: receiptsCollectionView)){
            
            switch listReceipts[indexpath.item].booking_status_id {
            case 0, 1, 2, 4:
                PublicFunction().showUnderstandDialog(self, "Cant Send Receipts", "Your parking order not completed yet, or maybe canceled due to system and provicy policy", "Understand")
            default:
                let sendReceiptsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SendReceiptController") as! SendReceiptController
                sendReceiptsController.receiptsModel = self.listReceipts[indexpath.item]
                self.navigationController?.pushViewController(sendReceiptsController, animated: true)
            }
            
        }
    }
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
}
