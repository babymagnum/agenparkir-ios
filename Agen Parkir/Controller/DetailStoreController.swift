//
//  DetailStoreController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class DetailStoreController: UIViewController, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var viewIconTop: UIView!
    
    //MARK: Props
    var stores_id: String?
    var listProduct = [ProductModel]()
    var operation = OperationQueue()
    var storeDetail: StoreModel?
    var page = 1
    var lastVelocityYSign = 0
    var allowLoadMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customView()
        
        initCollectionView()
        
        handleGesture()
        
        loadStore()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.productCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func loadStore() {
        SVProgressHUD.show()
        
        let detailStoreOperation = DetailStoreOperation((stores_id: stores_id!, page: page))
        operation.addOperation(detailStoreOperation)
        detailStoreOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch detailStoreOperation.state {
                case .success?:
                    for (index, product) in (detailStoreOperation.listProduct.enumerated()) {
                        self.listProduct.append(product)
                        
                        if index == (detailStoreOperation.listProduct.count) - 1 {
                            self.page += 1
                            self.productCollectionView.reloadData()
                        }
                    }
                case .empty?:
                    if self.listProduct.count == 0 {
                        PublicFunction().showUnderstandDialog(self, "No Products", "This store dont register their products yet", "Understand")
                    }
                case .error?:
                    if self.listProduct.count == 0 {
                        PublicFunction().showUnderstandDialog(self, "Error", detailStoreOperation.error!, "Understand")
                    }
                default:
                    if self.listProduct.count == 0 {
                        PublicFunction().showUnderstandDialog(self, "Error", "There was something error with system, please try again later", "Understand")
                    }
                }
            }
        }
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func customView() {
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x00A551, alpha: 1.0)
        viewIconTop.layer.cornerRadius = viewIconTop.frame.height / 2
    }
    
    private func initCollectionView() {
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.isPrefetchingEnabled = false
        productCollectionView.register(UINib(nibName: "StoreHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "StoreHeaderReusableView")
    }
}

extension DetailStoreController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //handle if the user reach the bottom of collection view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listProduct.count - 2 {
            if self.allowLoadMore {
                self.loadStore()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let product = listProduct[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        let approximateTextWidth = UIScreen.main.bounds.width - 95
        let size = CGSize(width: approximateTextWidth, height: 54)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let estimatedFrame = NSString(string: product.product_description!).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return CGSize(width: UIScreen.main.bounds.width, height: estimatedFrame.height + cell.name.frame.height + 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listProduct.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.dataProducts = listProduct[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StoreHeaderReusableView", for: indexPath) as! StoreHeaderReusableView
        headerView.dataHeader = self.storeDetail
        return headerView
        
//        switch kind {
//            case UICollectionView.elementKindSectionHeader:
//                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StoreHeaderReusableView", for: indexPath) as! StoreHeaderReusableView
//                headerView.dataHeader = self.storeDetail
//                return headerView
//            default:
//                assert(false, "Unexpected element kind")
//        }
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
        
        return CGSize(width: UIScreen.main.bounds.width, height: 294)
    }
}

extension DetailStoreController {
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
}
