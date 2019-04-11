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

class TicketingController: BaseViewController, UICollectionViewDelegate, IndicatorInfoProvider {

    @IBOutlet weak var ticketCollectionView: UICollectionView!
    @IBOutlet weak var emptyTicket: UILabel!
    
    var listTicket = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCollection()
        
        loadTicket()
    }
    
    private func loadTicket() {
        SVProgressHUD.show()
        
        let operation = OperationQueue()
        let ticketOngoing = TicketListOngoingOperation()
        operation.addOperation(ticketOngoing)
        ticketOngoing.completionBlock = {
            SVProgressHUD.dismiss()
            
            DispatchQueue.main.async {
                switch ticketOngoing.state {
                case .success?:
                    self.listTicket = ticketOngoing.listTicket
                    self.ticketCollectionView.reloadData()
                case .error?:
                    PublicFunction().showUnderstandDialog(self, "Error", ticketOngoing.error!, "Understand")
                    self.emptyTicket.isHidden = false
                case .empty?:
                    PublicFunction().showUnderstandDialog(self, "No Active Ticket", "You have no active ticket yet", "Understand")
                    self.emptyTicket.isHidden = false
                default:
                    PublicFunction().showUnderstandDialog(self, "Error", ticketOngoing.error!, "Understand")
                    self.emptyTicket.isHidden = false
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        ticketCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func initCollection() {
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


