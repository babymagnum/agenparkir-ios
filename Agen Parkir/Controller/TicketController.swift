//
//  TicketController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 18/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class TicketController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var viewIconTop: UIView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var ticketCollectionView: UICollectionView!
    
    var building_name: String?
    var building_id: Int?
    var popRecognizer: InteractivePopRecognizer?
    var listTicket = [TicketModel]()
    let operation = OperationQueue()
    var venueTicketModel: VenueTicketModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()
        
        customView()
        
        initCollectionView()
        
        loadInitialData()
        
        handleGesture()
    }
    
    private func loadInitialData() {
        if let data = venueTicketModel {
            self.building_name = data.name_building
            
            if data.ticketing.count == 0 {
                PublicFunction().showUnderstandDialog(self, "No Event", "This venue has no active or upcoming event yet.", "Understand")
                return
            }
            
            self.listTicket = data.ticketing
            self.ticketCollectionView.reloadData()
        }
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func customView() {
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x00A551, alpha: 0.8)
        viewIconTop.layer.cornerRadius = viewIconTop.frame.height / 2
    }
    
    private func loadTicket() {
        SVProgressHUD.show()
        
        let ticketOperation = TicketOperation(building_id: building_id!)
        operation.addOperations([ticketOperation], waitUntilFinished: false)
        ticketOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch ticketOperation.state {
                case .success?:
                    if ticketOperation.listTicket.count == 0 {
                        PublicFunction().showUnderstandDialog(self, "Empty Ticket", "This venue dont have upcoming or active event yet.", "Understand")
                        return
                    }
                    
                    for (index, ticket) in ticketOperation.listTicket.enumerated() {
                        self.listTicket.append(ticket)
                        
                        if index == ticketOperation.listTicket.count - 1 {
                            self.ticketCollectionView.reloadData()
                        }
                    }
                case .error?:
                    PublicFunction().showUnderstandDialog(self, "Error", ticketOperation.error!, "Understand")
                default:
                    PublicFunction().showUnderstandDialog(self, "Error", "There was some error with system, please try again", "Understand")
                }
            }
        }
    }
    
    private func initCollectionView() {
        ticketCollectionView.showsVerticalScrollIndicator = false
        ticketCollectionView.delegate = self
        ticketCollectionView.dataSource = self
        ticketCollectionView.register(UINib(nibName: "StadionHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "StadionHeaderReusableView")
        
        let cell = ticketCollectionView.dequeueReusableCell(withReuseIdentifier: "TicketCell", for: IndexPath(item: 0, section: 0)) as! TicketCell
        let layout = ticketCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: cell.contentMain.frame.height)
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
}

extension TicketController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listTicket.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketCell", for: indexPath) as! TicketCell
        cell.dataTicket = listTicket[indexPath.item]
        cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentMainClick(sender:))))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
//        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StadionHeaderReusableView", for: indexPath) as! StadionHeaderReusableView
//        headerView.venueData = self.venueTicketModel
//        return headerView
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StadionHeaderReusableView", for: indexPath) as! StadionHeaderReusableView
            headerView.venueData = self.venueTicketModel
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "StoreHeaderReusableView", for: IndexPath(item: 0, section: section)) as! StoreHeaderReusableView
        //
        //        let approximateDescriptionWidth = UIScreen.main.bounds.width - 100
        //        let sizeDescription = CGSize(width: approximateDescriptionWidth, height: 60)
        //        let attributesDescription = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
        //        let estimatedFrameDescription = NSString(string: (self.storeDetail?.store_description)!).boundingRect(with: sizeDescription, options: .usesLineFragmentOrigin, attributes: attributesDescription, context: nil)
        //
        //        let approximateAddressWidth = UIScreen.main.bounds.width - 100
        //        let sizeAddress = CGSize(width: approximateAddressWidth, height: 60)
        //        let attributesAddress = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
        //        let estimatedFrameAddress = NSString(string: (self.storeDetail?.buildings_address)!).boundingRect(with: sizeAddress, options: .usesLineFragmentOrigin, attributes: attributesAddress, context: nil)
        //
        //        let height = headerView.viewTop.frame.height + 80 + estimatedFrameDescription.height + estimatedFrameAddress.height
        
        return CGSize(width: UIScreen.main.bounds.width, height: 334)
    }
}

extension TicketController {
    @objc func contentMainClick(sender: UITapGestureRecognizer) {
        if let indexpath = ticketCollectionView.indexPathForItem(at: sender.location(in: ticketCollectionView)) {
            let ticketDetailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TicketDetailController") as! TicketDetailController
            ticketDetailController.ticketModel = listTicket[indexpath.row]
            ticketDetailController.building_name = self.building_name
            navigationController?.pushViewController(ticketDetailController, animated: true)
        }
    }
    
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
}
