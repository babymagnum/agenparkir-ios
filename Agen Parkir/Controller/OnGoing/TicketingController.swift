//
//  TicketingController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 21/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

class TicketingController: BaseViewController, UICollectionViewDelegate, IndicatorInfoProvider, BaseViewControllerProtocol {

    @IBOutlet weak var ticketCollectionView: UICollectionView!
    @IBOutlet weak var emptyTicket: UILabel!
    
    var listTicket = [String]()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTicket()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCollection()
        
        baseDelegate = self
        
        handleGesture()
    }
    
    private func handleGesture() {
        emptyTicket.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyTicketClick)))
    }
    
    // function from BaseViewController //
    func hasInternet() {
        emptyTicket.text = "You have no active ticket yet."
    }
    
    // function from BaseViewController //
    func noInternet() {
        emptyTicket.attributedText = reloadString()
        
        if listTicket.count == 0 {
            emptyTicket.isHidden = false
        }
    }
    
    private func loadTicket() {
        SVProgressHUD.show()
        
        let operation = OperationQueue()
        let ticketOngoing = TicketListOngoingOperation()
        operation.addOperation(ticketOngoing)
        ticketOngoing.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch ticketOngoing.state {
                case .success?:
                    self.emptyTicket.isHidden = true
                    self.listTicket = ticketOngoing.listTicket
                    self.ticketCollectionView.reloadData()
                case .error?:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", ticketOngoing.error!, "Understand")
                    self.showEmpty()
                case .empty?:
                    self.showEmpty()
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", ticketOngoing.error!, "Understand")
                    self.showEmpty()
                }
            }
        }
    }
    
    private func showEmpty() {
        emptyTicket.text = "You have no active ticket yet."
        emptyTicket.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        ticketCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func initCollection() {
        ticketCollectionView.addSubview(refreshControl)
        ticketCollectionView.delegate = self
        ticketCollectionView.dataSource = self
        ticketCollectionView.isPrefetchingEnabled = false
        
        let layout = ticketCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cell = ticketCollectionView.dequeueReusableCell(withReuseIdentifier: "ReceiptTicketCell", for: IndexPath(item: 0, section: 0)) as! ReceiptTicketCell
        let height = cell.venueName.frame.height + cell.eventName.frame.height + cell.date.frame.height + 48
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: height)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Ticketing")
    }
}

extension TicketingController {
    @objc func emptyTicketClick() {
        loadTicket()
    }
    
    @objc func handleRefresh(_ refresh: UIRefreshControl) {
        loadTicket()
        
        refresh.endRefreshing()
    }
}

extension TicketingController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listTicket.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReceiptTicketCell", for: indexPath) as! ReceiptTicketCell
        cell.orders_id = listTicket[indexPath.row]
        cell.controller = self
        cell.delegate = self
        return cell
    }
}

extension TicketingController: ReceiptTicketProtocol {
    func contentMain(_ ticketModel: TicketDetailModel) {
        let ticketReceiptController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TicketDetailReceiptController") as! TicketDetailReceiptController
        ticketReceiptController.ticketModel = ticketModel
        navigationController?.pushViewController(ticketReceiptController, animated: true)
    }
}


