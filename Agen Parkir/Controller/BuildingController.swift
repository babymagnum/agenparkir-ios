//
//  BookingController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 09/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class BuildingController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var emptyText: UILabel!
    @IBOutlet weak var iconSearchContent: UIImageView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var inputSearch: UITextField!
    @IBOutlet weak var contentSearch: UIView!
    @IBOutlet weak var viewSearchHeight: NSLayoutConstraint!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var iconSearch: UIImageView!
    @IBOutlet weak var buildingCollectionView: UICollectionView!
    
    //MARK: Props
    var listBuilding = [BuildingModel]()
    var listSearchBuilding = [BuildingModel]()
    var currentPage = 1
    var currentSearchPage = 1
    var inSearch = false
    var doingSearch = false
    let operation = OperationQueue()
    var lastVelocityYSign = 0
    var allowLoadMore = false
    var popRecognizer: InteractivePopRecognizer?
    var lastVisibleIndexPath = IndexPath(item: 0, section: 0)
    var lastVisibleSearchIndexPath = IndexPath(item: 0, section: 0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()
        
        customView()

        initCollectionView()
        
        loadBuilding()
        
        handleGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.buildingCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func customView() {
        inputSearch.tag = 1
        inputSearch.delegate = self
        iconSearchContent.image = UIImage(named: "search")?.tinted(with: UIColor.lightGray)
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
        PublicFunction().changeTintColor(imageView: iconSearch, hexCode: 0x2B3990, alpha: 1.0)
        
        contentSearch.layer.borderWidth = 1
        contentSearch.layer.borderColor = UIColor(rgb: 0xEFEFEF).cgColor
        contentSearch.layer.cornerRadius = contentSearch.frame.height / 2
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        iconSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconSearchClick)))
    }
    
    private func loadBuilding() {
        SVProgressHUD.show()
        let showListOperation = ShowListBuildingOperation((pageNumber: currentPage, purpose: LoadBuilding.booking, nameQuery: ""))
        operation.addOperations([showListOperation], waitUntilFinished: false)
        showListOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            switch showListOperation.state {
            case .success?:
                for (index, building) in showListOperation.listBuilding.enumerated() {
                    self.listBuilding.append(building)
                    
                    if index == showListOperation.listBuilding.count - 1 {
                        DispatchQueue.main.async {
                            self.buildingCollectionView.reloadData()
                            
                            self.currentPage += 1
                        }
                    }
                }
            case .error?:
                PublicFunction().showUnderstandDialog(self, "Error", "\(showListOperation.error ?? "")", "Understand")
            case .empty?:
                print("empty")
            default:
                PublicFunction().showUnderstandDialog(self, "Error", "There was something error, please refresh this page", "Understand")
            }
        }
    }
    
    private func initCollectionView() {
        let cell = buildingCollectionView.dequeueReusableCell(withReuseIdentifier: "BuildingCell", for: IndexPath(item: 0, section: 0)) as! BuildingCell
        let layout = buildingCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let height = cell.contentMain.frame.height
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: height)
        
        buildingCollectionView.delegate = self
        buildingCollectionView.dataSource = self
        buildingCollectionView.isPrefetchingEnabled = false
    }
    
    private func loadInitialTicket(_ building_id: String) {
        SVProgressHUD.show()
        
        let ticketOperation = TicketOperation(building_id: Int(building_id)!)
        operation.addOperation(ticketOperation)
        
        ticketOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch ticketOperation.state {
                case .success?:
                    let ticketController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TicketController") as! TicketController
                    ticketController.venueTicketModel = ticketOperation.venueTicketModel
                    self.navigationController?.pushViewController(ticketController, animated: true)
                case .error?:
                    PublicFunction().showUnderstandDialog(self, "Error", ticketOperation.error!, "Understand")
                default:
                    PublicFunction().showUnderstandDialog(self, "Error", ticketOperation.error!, "Understand")
                }
            }
        }
    }
    
    private func showEmptySearch() {
        if listSearchBuilding.count == 0 {
            self.emptyText.isHidden = false
            //self.listSearchBuilding.removeAll()
            self.buildingCollectionView.reloadData()
        }
    }
    
    private func loadBuildingBySearch() {
        SVProgressHUD.show()
        let buildingList = ShowListBuildingOperation((pageNumber: currentSearchPage, purpose: LoadBuilding.booking, nameQuery: (inputSearch.text?.trim())!))
        operation.addOperation(buildingList)
        buildingList.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                switch buildingList.state {
                case .success?:
                    for (index, value) in buildingList.listBuilding.enumerated() {
                        self.listSearchBuilding.append(value)
                        
                        if index == buildingList.listBuilding.count - 1 {
                            self.currentSearchPage += 1
                            
                            self.buildingCollectionView.reloadData()
                            
                            self.buildingCollectionView.isHidden = false
                            
                            self.emptyText.isHidden = true
                        }
                    }
                case .error?:
                    self.showEmptySearch()
                case .empty?:
                    self.showEmptySearch()
                default:
                    self.showEmptySearch()
                }
            }
        }
    }
}

//MARK: Handle gesture
extension BuildingController{
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func iconSearchClick() {
        //hide search bar
        if inSearch {
            self.inSearch = false
            self.viewSearch.isHidden = true
            
            iconSearch.image = UIImage(named: "search")?.tinted(with: UIColor(rgb: 0x2B3990))
            
            UIView.animate(withDuration: 0.2) {
                self.viewSearchHeight.constant = 0
                self.view.layoutIfNeeded()
            }
            
            if self.doingSearch {
                self.doingSearch = false
                self.buildingCollectionView.reloadData()
                self.buildingCollectionView.scrollToItem(at: self.lastVisibleIndexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
            } else {
                buildingCollectionView.isHidden = false
            }
            
            if self.listBuilding.count > 0 {
                self.emptyText.isHidden = true
            } else {
                self.emptyText.isHidden = false
            }
        }
        //show search bar
        else {
            self.inSearch = true
            viewSearch.isHidden = false
            buildingCollectionView.isHidden = true
            
            iconSearch.image = UIImage(named: "Artboard 240@0.75x-8")?.tinted(with: UIColor(rgb: 0x2B3990))
            
            UIView.animate(withDuration: 0.2) {
                self.viewSearchHeight.constant = 50
                self.view.layoutIfNeeded()
            }
            
            if self.listSearchBuilding.count > 0 {
                self.buildingCollectionView.reloadData()
                self.buildingCollectionView.scrollToItem(at: self.lastVisibleSearchIndexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
                self.buildingCollectionView.isHidden = false
            } else {
                self.emptyText.isHidden = false
            }
        }
    }
}

extension BuildingController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //handle if the user reach the bottom of collection view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listBuilding.count - 3 {
            if self.allowLoadMore {
                if inSearch {
                    loadBuildingBySearch()
                } else {
                    loadBuilding()
                }
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
        return inSearch ? listSearchBuilding.count : listBuilding.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuildingCell", for: indexPath) as! BuildingCell
        cell.buildingData = inSearch ? listSearchBuilding[indexPath.row] : listBuilding[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if inSearch {
            self.lastVisibleSearchIndexPath = buildingCollectionView.indexPathsForVisibleItems.first!
        } else {
            self.lastVisibleIndexPath = buildingCollectionView.indexPathsForVisibleItems.first!
        }
    }
}

extension BuildingController: BuildingCellProtocol{
    func viewClick(_ content: String, _ data: (building_id: String, address: String, building_name: String)) {
        switch content {
        case "Book Parking":
            let bookingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookingController") as! BookingController
            bookingController.building_id = Int(data.building_id)
            navigationController?.pushViewController(bookingController, animated: true)
        case "Buy Ticket":
            loadInitialTicket(data.building_id)
        default:
            let storeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreController") as! StoreController
            storeController.data = (building_id: data.building_id, address: data.address, building_name: data.building_name)
            navigationController?.pushViewController(storeController, animated: true)
        }

    }
}

extension BuildingController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            //remove previous search
            self.listSearchBuilding.removeAll()
            //change flag
            self.doingSearch = true
            //hide keyboard
            inputSearch.resignFirstResponder()
            //do search operation
            loadBuildingBySearch()
        }
        
        return true
    }
}
