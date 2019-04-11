//
//  MyCardController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 16/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class MyCardController: BaseViewController, UICollectionViewDelegate, BaseViewControllerProtocol {
    
    //MARK: Outlet
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var textSaldo: UIButton!
    @IBOutlet weak var customerAmount: UILabel!
    @IBOutlet weak var viewSaldo: UIView!
    @IBOutlet weak var iconTopUp: UIImageView!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var contentMyCard: UIView!
    
    //MARK: Props
    var lastVelocityYSign = 0
    var operation = OperationQueue()
    var listHistory = [HistoryModel]()
    var currentPage = 1
    var allowLoadMore = false
    var popRecognizer: InteractivePopRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInteractiveRecognizer()
        
        customView()
        
        handleGesture()
        
        initCollectionView()
        
        loadData()    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.historyCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func loadHistory() {
        SVProgressHUD.show()
        
        let historyOperation = HistoryOperation((customer_id: UserDefaults.standard.string(forKey: StaticVar.id)!, current_page: currentPage))
        operation.addOperation(historyOperation)
        historyOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch historyOperation.state {
                case .success?:
                    self.emptyLabel.isHidden = true
                    self.currentPage += 1
                    
                    for (index, history) in historyOperation.listHistory.enumerated() {
                        self.listHistory.append(history)
                        
                        if index == historyOperation.listHistory.count - 1 {
                            self.historyCollectionView.reloadData()
                        }
                    }
                case .error?, .empty?:
                    if self.listHistory.count == 0 {
                        self.emptyLabel.isHidden = false
                    }
                default:
                    if self.listHistory.count == 0 {
                        self.emptyLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    private func initCollectionView() {
        historyCollectionView.delegate = self
        historyCollectionView.dataSource = self
        historyCollectionView.showsVerticalScrollIndicator = false
        historyCollectionView.isPrefetchingEnabled = false
    }
    
    private func loadData() {
        SVProgressHUD.show()
        
        let currentOperation = CurrentOperation()
        let historyOperation = HistoryOperation((customer_id: UserDefaults.standard.string(forKey: StaticVar.id)!, current_page: currentPage))
        operation.addOperations([currentOperation, historyOperation], waitUntilFinished: false)
        
        currentOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch currentOperation.state {
                case .success?:
                    self.updateUI(currentOperation.currentModel!)
                case .error?:
                    PublicFunction().showUnderstandDialog(self, "Error", currentOperation.error!, "Understand")
                default:
                    PublicFunction().showUnderstandDialog(self, "Error", "There was some error with system, please try again", "Understand")
                }
            }
        }
        
        historyOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch historyOperation.state {
                case .success?:
                    self.emptyLabel.isHidden = true
                    self.currentPage += 1
                    
                    for (index, history) in historyOperation.listHistory.enumerated() {
                        self.listHistory.append(history)
                        
                        if index == historyOperation.listHistory.count - 1 {
                            self.historyCollectionView.reloadData()
                        }
                    }
                case .error?, .empty?:
                    if self.listHistory.count == 0 {
                        self.emptyLabel.isHidden = false
                    }
                default:
                    if self.listHistory.count == 0 {
                        self.emptyLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    private func updateUI(_ data: CurrentModel) {
        customerAmount.text = data.getMyCard()
        customerName.text = data.name
    }
    
    func noInternet() {
        emptyLabel.attributedText = reloadString()
        
        if listHistory.count == 0 {
            emptyLabel.isHidden = false
        }
    }
    
    func hasInternet() {
        emptyLabel.text = "You haven't make any transaction yet."
    }
    
    private func customView() {
        baseDelegate = self
        viewSaldo.layer.cornerRadius = viewSaldo.frame.height / 2
        viewSaldo.clipsToBounds = false
        viewSaldo.layer.shadowColor = UIColor.lightGray.cgColor
        viewSaldo.layer.shadowOffset = CGSize(width: 1, height: 2)
        viewSaldo.layer.shadowRadius = 2
        viewSaldo.layer.shadowOpacity = 0.6
        textSaldo.clipsToBounds = true
        textSaldo.layer.cornerRadius = textSaldo.frame.height / 2
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
        contentMyCard.layer.cornerRadius = 5
        contentMyCard.clipsToBounds = false
        contentMyCard.layer.shadowColor = UIColor.lightGray.cgColor
        contentMyCard.layer.shadowOffset = CGSize(width: 1, height: 2)
        contentMyCard.layer.shadowRadius = 2
        contentMyCard.layer.shadowOpacity = 0.6
    }
    
    private func handleGesture(){
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        iconTopUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTopUpClick)))
        emptyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyLabelClick)))
    }
}

extension MyCardController {
    @objc func emptyLabelClick() {
        loadData()
        loadHistory()
    }
    
    @objc func iconTopUpClick() {
        let topupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopupController") as! TopupController
        topupController.delegate = self
        navigationController?.pushViewController(topupController, animated: true)
    }
    
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
}

extension MyCardController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //handle if the user reach the bottom of collection view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listHistory.count - 1 {
            if self.allowLoadMore {
                self.loadHistory()
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
        return listHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        cell.dataHistory = listHistory[indexPath.row]
        
        switch listHistory[indexPath.row].event_id {
        case 1:
            cell.transactionLabel.text = "Top Up"
            cell.icon.image = UIImage(named: "Artboard 180@0.75x-8")
            cell.amount.text = "+Rp\(PublicFunction().prettyRupiah(String((listHistory[indexPath.row].nominal?.dropLast(5))!)))"
        case 2:
            cell.transactionLabel.text = "Booking"
            cell.icon.image = UIImage(named: "Artboard 178@0.75x-8")
            cell.amount.text = "-Rp\(PublicFunction().prettyRupiah(String((listHistory[indexPath.row].nominal?.dropLast(5))!)))"
        default:
            cell.transactionLabel.text = "Ticketing"
            cell.icon.image = UIImage(named: "Artboard 179@0.75x-8")
            cell.amount.text = "-Rp\(PublicFunction().prettyRupiah(String((listHistory[indexPath.row].nominal?.dropLast(5))!)))"
        }
        
        let millis = PublicFunction().dateStringToInt(stringDate: listHistory[indexPath.row].trans_date!, pattern: "yyyy-MM-dd kk:mm:ss")
        let date = PublicFunction().dateLongToString(dateInMillis: millis, pattern: "dd MMMM yyyy")
        
        let originalHeight = cell.view1Height.constant + cell.view2Height.constant + 30 + cell.topDateHeight.constant + 3
        let minimalisHeight = cell.view1Height.constant + cell.view2Height.constant + 30
        
        if indexPath.row > 0 {
            let millisBefore = PublicFunction().dateStringToInt(stringDate: listHistory[indexPath.row - 1].trans_date!, pattern: "yyyy-MM-dd kk:mm:ss")
            let dateBefore = PublicFunction().dateLongToString(dateInMillis: millisBefore, pattern: "dd MMMM yyyy")
            
            if dateBefore == date {
                cell.topDate.text = ""
                cell.topDateHeight.constant = 0
                cell.contentMainHeight.constant = minimalisHeight
            } else {
                cell.topDate.text = date
                cell.topDateHeight.constant = 15
                cell.contentMainHeight.constant = originalHeight
            }
        } else {
            cell.topDate.text = date
            cell.topDateHeight.constant = 15
            cell.contentMainHeight.constant = originalHeight
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        
        let originalHeight = cell.view1Height.constant + cell.view2Height.constant + 30 + cell.topDateHeight.constant + 3
        let minimalisHeight = cell.view1Height.constant + cell.view2Height.constant + 30
        
        if indexPath.row > 0 {
            let millis = PublicFunction().dateStringToInt(stringDate: listHistory[indexPath.row].trans_date!, pattern: "yyyy-MM-dd kk:mm:ss")
            let date = PublicFunction().dateLongToString(dateInMillis: millis, pattern: "dd MMMM yyyy")
            let millisBefore = PublicFunction().dateStringToInt(stringDate: listHistory[indexPath.row - 1].trans_date!, pattern: "yyyy-MM-dd kk:mm:ss")
            let dateBefore = PublicFunction().dateLongToString(dateInMillis: millisBefore, pattern: "dd MMMM yyyy")
            
            if dateBefore == date {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: minimalisHeight)
            } else {
                return CGSize(width: UIScreen.main.bounds.width - 40, height: originalHeight)
            }
        } else {
            return CGSize(width: UIScreen.main.bounds.width - 40, height: originalHeight)
        }
    }
}

extension MyCardController: UpdateCurrentDataProtocol {
    func updateData() {
        SVProgressHUD.show()
        let currentOperation = CurrentOperation()
        operation.addOperation(currentOperation)
        
        currentOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            if let err = currentOperation.error {
                PublicFunction().showUnderstandDialog(self, "Error", err, "Understand")
            }
            
            guard let currentModel = currentOperation.currentModel else { return }
            
            DispatchQueue.main.async {
                self.updateUI(currentModel)
            }
        }
    }
}
