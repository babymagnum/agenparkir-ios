//
//  OngoingInfoController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 14/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class OngoingInfoController: UIViewController, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconClose: UIImageView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var plateNumber: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var bookingCode: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var parkingLot: UILabel!
    @IBOutlet weak var viewCars: UIView!
    @IBOutlet weak var viewMotorcycle: UIView!
    @IBOutlet weak var viewVallet: UIView!
    @IBOutlet weak var viewStandart: UIView!
    @IBOutlet weak var viewIndoor: UIView!
    @IBOutlet weak var viewOutdoor: UIView!
    @IBOutlet weak var viewCredit: UIView!
    @IBOutlet weak var viewCash: UIView!
    @IBOutlet weak var viewMycard: UIView!
    @IBOutlet weak var viewKetentuanParkir: UIView!
    @IBOutlet weak var textStoreInThisPlace: UILabel!
    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    @IBOutlet weak var iconKetentuanParkir: UIImageView!
    @IBOutlet weak var storeCollectionViewHeight: NSLayoutConstraint!
    
    //MARK: Props
    var ongoingModel: OngoingModel?
    var listImages = [String]()
    var listStores = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        initCollectionView()
        
        customView()
        
        handleGesture()
        
        loadInfo()
    }
    
    private func initCollectionView(){
        //images coll view
        let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ImagesOngoingCell", for: IndexPath(item: 0, section: 0)) as! ImagesOngoingCell
//        let cellScalling: CGFloat = 0.8
//        let screenSize = UIScreen.main.bounds.size
//        let height: CGFloat = cell.image.frame.height
//        let width = floor(screenSize.width * cellScalling)
//        let insetX = (view.bounds.width - width) / 2.0
        
        let imageCollectionLayout = imagesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        imageCollectionLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: cell.image.frame.height)
        //imageCollectionLayout.sectionInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.isPagingEnabled = true
        imagesCollectionView.showsHorizontalScrollIndicator = false
        
        //stores coll view
        let storeCollectionLayout = storeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        storeCollectionLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 4 - 10, height: 100)
        storeCollectionView.delegate = self
        storeCollectionView.dataSource = self
    }
    
    private func loadInfo() {
        if let model = ongoingModel {
            SVProgressHUD.show()
            
            let operation = OperationQueue()
            let detailOngoingOperation = DetailOngoingOperation(order_id: model.order_id!)
            operation.addOperation(detailOngoingOperation)
            detailOngoingOperation.completionBlock = {
                SVProgressHUD.dismiss()
                
                switch detailOngoingOperation.state{
                case .success?:
                    if let data = detailOngoingOperation.returnDetailOngoing {
                        
                        DispatchQueue.main.async {
                            self.venueName.text = data.building_name
                            self.parkingLot.text = "[ \(data.parking_lot) ]"
                            self.plateNumber.text = "[ \(data.plate_number) ]"
                            self.price.text = "[ Rp\(PublicFunction().prettyRupiah("\(data.tariff)")) ]"
                            self.bookingCode.text = data.booking_code
                            
                            if data.vehicle_types_id == 1 {
                                self.viewCars.isHidden = true
                            } else {
                                self.viewMotorcycle.isHidden = true
                            }
                            
                            if data.parking_types == 0 {
                                self.viewVallet.isHidden = true
                            } else {
                                self.viewStandart.isHidden = true
                            }
                            
                            if data.type == "in" {
                                self.viewOutdoor.isHidden = true
                            } else {
                                self.viewIndoor.isHidden = true
                            }
                            
                            switch data.payment_types_id {
                            case 1:
                                self.viewCash.isHidden = true
                                self.viewMycard.isHidden = true
                            case 2:
                                self.viewCredit.isHidden = true
                                self.viewMycard.isHidden = true
                            default:
                                self.viewCredit.isHidden = true
                                self.viewCash.isHidden = true
                            }
                            
                            self.listImages = data.images
                            self.imagesCollectionView.reloadData()
                            
                            self.contentMainHeight.constant -= self.storeCollectionViewHeight.constant - 10
                            
                            if data.store_list.count == 0 {
                                self.storeCollectionViewHeight.constant = 0
                                self.textStoreInThisPlace.isHidden = true
                            } else {
                                self.listStores = data.store_list
                                self.storeCollectionView.reloadData()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                    self.storeCollectionViewHeight.constant = self.storeCollectionView.contentSize.height
                                    self.contentMainHeight.constant += self.storeCollectionViewHeight.constant
                                })
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                UIView.animate(withDuration: 0.1, animations: {
                                    self.view.layoutIfNeeded()
                                })
                            })
                        }
                        
                    }
                case .error?:
                    PublicFunction().showUnderstandDialog(self, "Error", detailOngoingOperation.error!, "Understand")
                default:
                    PublicFunction().showUnderstandDialog(self, "Error", "There was something error with system, please refresh this page", "Understand")
                }
            }
        }
    }
    
    private func handleGesture() {
        iconClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconCloseClick)))
    }
    
    private func customView() {
        PublicFunction().changeTintColor(imageView: iconKetentuanParkir, hexCode: 0x555555, alpha: 1.0)
        PublicFunction().changeTintColor(imageView: iconClose, hexCode: 0x000000, alpha: 0.8)
    }
}

extension OngoingInfoController {
    @objc func iconCloseClick() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Collection view
extension OngoingInfoController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imagesCollectionView {
            return listImages.count
        } else {
            return listStores.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesOngoingCell", for: indexPath) as! ImagesOngoingCell
            cell.imageData = listImages[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesOngoingCell", for: indexPath) as! ImagesOngoingCell
            cell.imageData = listStores[indexPath.item]
            return cell
        }
    }
}
