//
//  StoreController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class StoreController: BaseViewController, UICollectionViewDelegate, UITextFieldDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var viewIconTop: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var emptyText: UILabel!
    @IBOutlet weak var iconSearch: UIImageView!
    @IBOutlet weak var inputSearch: UITextField!
    @IBOutlet weak var storeCollectionView: UICollectionView!
    
    //MARK: Props
    var listStore = [StoreModel]()
    let operation = OperationQueue()
    var popRecognizer: InteractivePopRecognizer?
    var data: (building_id: String, address: String, building_name: String)?
    var page = 1
    var lastVelocityYSign = 0
    var allowLoadMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customView()
        
        initCollectionView()
        
        loadStore()
        
        handleGesture()
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func customView() {
        inputSearch.delegate = self
        inputSearch.tag = 1
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x00A551, alpha: 1.0)
        iconSearch.image = UIImage(named: "search")?.tinted(with: UIColor.lightGray.withAlphaComponent(0.6))
        viewSearch.layer.cornerRadius = viewSearch.frame.height / 2
        viewSearch.layer.borderWidth = 1
        viewSearch.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        viewIconTop.layer.cornerRadius = viewIconTop.frame.height / 2
    }
    
    private func loadStore() {
        SVProgressHUD.show()
        
        let listStore = ListStoreOperation((building_id: (data?.building_id)!, address: (data?.address)!, page: page))
        operation.addOperation(listStore)
        
        listStore.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch listStore.state {
                case .success?:
                    for (index, store) in listStore.listStore.enumerated() {
                        self.listStore.append(store)
                        
                        if index == listStore.listStore.count - 1 {
                            self.page += 1
                            self.storeCollectionView.reloadData()
                        }
                    }
                case .error?:
                    if self.listStore.count == 0 {
                        self.emptyText.isHidden = false
                        PublicFunction().showUnderstandDialog(self, "Error", listStore.error!, "Understand")
                    }
                case .empty?:
                    if self.listStore.count == 0 {
                        self.emptyText.isHidden = false
                        PublicFunction().showUnderstandDialog(self, "Error", "This building has no store registered yet", "Understand")
                    }
                default:
                    if self.listStore.count == 0 {
                        self.emptyText.isHidden = false
                        PublicFunction().showUnderstandDialog(self, "Error", "There was some error with system, please try again", "Understand")
                    }
                }
            }
        }
    }

    private func initCollectionView() {
        let cell = storeCollectionView.dequeueReusableCell(withReuseIdentifier: "StoreCell", for: IndexPath(item: 0, section: 0)) as! StoreCell
        let layout = storeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let height = 80 + cell.storeName.frame.height
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: height)
        
        storeCollectionView.delegate = self
        storeCollectionView.dataSource = self
    }
}

extension StoreController: UICollectionViewDataSource{
    //handle if the user reach the bottom of collection view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listStore.count - 2 {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listStore.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCell", for: indexPath) as! StoreCell
        cell.storeData = listStore[indexPath.row]
        cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentMainClick(sender:))))
        return cell
    }
}

extension StoreController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            PublicFunction().showUnderstandDialog(self, "Search is in Development", "Search function is in development", "Understand")
        }
        
        return true
    }
}

extension StoreController {
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func contentMainClick(sender: UITapGestureRecognizer) {
        if let indexpath = storeCollectionView.indexPathForItem(at: sender.location(in: storeCollectionView)) {
            let detailStore = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailStoreController") as! DetailStoreController
            detailStore.stores_id = "\(listStore[indexpath.row].store_id ?? 0)"
            detailStore.storeDetail = listStore[indexpath.row]
            navigationController?.pushViewController(detailStore, animated: true)
        }
    }
}
