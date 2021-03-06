//
//  ReceiptsController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 14/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class ReceiptsController: BaseViewController, UICollectionViewDelegate, BaseViewControllerProtocol {
    @IBOutlet weak var iconClearAll: UIImageView!
    @IBOutlet weak var viewClearAll: UIView!
    @IBOutlet weak var receiptsCollectionView: UICollectionView!
    @IBOutlet weak var emptyReceipts: UILabel!
    @IBOutlet weak var iconBack: UIImageView!
    
    var lastVelocityYSign = 0
    var allowLoadMore = false
    var listReceipts = [ReceiptsModel]()
    var currentPage = 1
    var popRecognizer: InteractivePopRecognizer?
    var refresh = false
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()

        initCollectionView()
        
        customView()
        
        loadReceipts()
        
        handleGesture()
    }
    
    private func handleGesture() {
        emptyReceipts.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyReceiptsClick)))
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func loadReceipts() {
        SVProgressHUD.show()
        
        let operation = OperationQueue()
        let listReceiptsOperation = ListReceiptsOperation(currentPage: currentPage)
        operation.addOperation(listReceiptsOperation)
        listReceiptsOperation.completionBlock = {
            //update the ui in main thread
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch listReceiptsOperation.state {
                case .success?:
                    self.emptyReceipts.isHidden = true
                    if self.refresh == true { self.listReceipts.removeAll() }
                    
                    for (index, receipt) in listReceiptsOperation.listReceipts.enumerated() {
                        self.listReceipts.append(receipt)
                        
                        if index == listReceiptsOperation.listReceipts.count - 1{
                            self.receiptsCollectionView.reloadData()
                            self.currentPage += 1
                            self.refresh = false
                        }
                    }
                case .empty?:
                    if self.listReceipts.count == 0 {
                        self.showEmpty()
                        PublicFunction.instance.showUnderstandDialog(self, "Empty Receipts", "You haven't make any order yet", "Understand")
                    }
                case .error?:
                    if self.listReceipts.count == 0 {
                        self.showEmpty()
                        PublicFunction.instance.showUnderstandDialog(self, "Error", listReceiptsOperation.error!, "Understand")
                    }
                default:
                    if self.listReceipts.count == 0 {
                        self.showEmpty()
                        PublicFunction.instance.showUnderstandDialog(self, "Error", "There was something error with system, please refresh the page", "Understand")
                    }
                }
            }
        }
    }
    
    private func showEmpty() {
        emptyReceipts.text = "You haven't made any order yet."
        emptyReceipts.isHidden = false
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func initCollectionView() {
        receiptsCollectionView.addSubview(refreshControl)
        receiptsCollectionView.delegate = self
        receiptsCollectionView.dataSource = self
        
        let cell = receiptsCollectionView.dequeueReusableCell(withReuseIdentifier: "ReceiptsCell", for: IndexPath(item: 0, section: 0)) as! ReceiptsCell
        let layout = receiptsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let height = 30 + cell.venueName.frame.height + cell.message.frame.height + cell.orderDate.frame.height
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: height)
    }
    
    private func customView() {
        baseDelegate = self
        viewClearAll.layer.cornerRadius = viewClearAll.frame.height / 2
        viewClearAll.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        PublicFunction.instance.changeTintColor(imageView: iconClearAll, hexCode: 0xffffff, alpha: 1.0)
        PublicFunction.instance.changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
    }
    
    func noInternet() {
        emptyReceipts.attributedText = reloadString()
        
        if listReceipts.count == 0 {
            emptyReceipts.isHidden = false
        }
    }
    
    func hasInternet() {
        emptyReceipts.text = "You haven't made any order yet."
    }
}

extension ReceiptsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listReceipts.count - 1 {
            if allowLoadMore {
                self.loadReceipts()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
        let currentVelocityYSign = Int(currentVelocityY).signum()
        
        if currentVelocityYSign != lastVelocityYSign &&
            currentVelocityYSign != 0 {
            lastVelocityYSign = currentVelocityYSign
        }
        
        if lastVelocityYSign < 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.allowLoadMore = true
            }
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
                PublicFunction.instance.showUnderstandDialog(self, "Cant Send Receipts", "Your parking order not completed yet, or maybe canceled due to system and provicy policy", "Understand")
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
    
    @objc func emptyReceiptsClick() {
        loadReceipts()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh = true
        currentPage = 1
        loadReceipts()
        refreshControl.endRefreshing()
    }
}
