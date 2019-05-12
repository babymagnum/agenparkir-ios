//
//  VoucherController.swift
//  Agen Parkir
//  
//  Created by Arief Zainuri on 10/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

class VoucherController: UIViewController, UICollectionViewDelegate {

    //MARK: Outlet
    @IBOutlet weak var viewCoin: UIView!
    @IBOutlet weak var iconCoins: UIImageView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var viewCoinWidth: NSLayoutConstraint!
    @IBOutlet weak var amountCoin: UILabel!
    @IBOutlet weak var voucherCollectionView: UICollectionView!
    
    //MARK: Props
    var voucherList = [VoucherModel]()
    var popRecognizer: InteractivePopRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInteractiveRecognizer()
        
        customView()
        
        initCollectionView()
        
        getCoins()
        
        getVoucher()
        
        handleEvent()
    }
    
    private func customView() {
        iconBack.image = UIImage(named: "Artboard 230@0.75x-8")?.tinted(with: UIColor(rgb: 0xFB8C00))
        viewCoin.layer.cornerRadius = viewCoin.frame.height / 2
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func initCollectionView() {
        voucherCollectionView.delegate = self
        voucherCollectionView.dataSource = self
    }
    
    private func handleEvent() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func getCoins() {
        Networking.instance.getCoins(customer_id: UserDefaults.standard.string(forKey: StaticVar.id)!) { (coins, customer_id, error) in
            DispatchQueue.main.async {
                if let _ = error { return }
                
                let approximateTextWidth = self.amountCoin.frame.width - 10 - 10
                let size = CGSize(width: approximateTextWidth, height: 100)
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
                let estimatedFrame = NSString(string: "\(coins ?? 0)").boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewCoinWidth.constant = self.iconCoins.frame.width + estimatedFrame.width + 2.5 + 25
                    self.view.layoutIfNeeded()
                })
                
                self.amountCoin.text = "\(coins ?? 0)"
                
                
            }
        }
    }
    
    private func getVoucher() {
        SVProgressHUD.show()
        
        Networking.instance.getVoucherList { (list, error) in
            if let _ = error {
                SVProgressHUD.dismiss()
                return
            }
            
            guard let list = list else {
                SVProgressHUD.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                for (index, value) in list.enumerated() {
                    var dataValue = value
                    
                    dataValue.description = "Hanya dengan menukar coin sebanyak \(value.coin_price ?? 0) coin, kamu bisa mendapatkan saldo My Card sebanyak \(value.value ?? 0)."
                    
                    self.voucherList.append(dataValue)
                    
                    if index == list.count - 1 {
                        self.voucherCollectionView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
}

//MARK: Collection view
extension VoucherController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let service = voucherList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServicesCell", for: indexPath) as! ServicesCell
        
        let approximateTextWidth = cell.viewContentText.frame.width - 10 - 10
        let size = CGSize(width: approximateTextWidth, height: 100)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let estimatedFrame = NSString(string: service.description ?? "").boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return CGSize(width: UIScreen.main.bounds.width - 40, height: estimatedFrame.height + cell.servicesName.frame.height + 60 + cell.servicesDate.frame.height + cell.iconStar.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voucherList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServicesCell", for: indexPath) as! ServicesCell
        cell.servicesData = voucherList[indexPath.row]
        cell.buttonBuy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonBuyClick(sender:))))
        return cell
    }
}

//MARK: Handle Event
extension VoucherController {
    @objc func buttonBuyClick(sender: UITapGestureRecognizer){
        if let indexpath = voucherCollectionView.indexPathForItem(at: sender.location(in: voucherCollectionView)) {
            let detailVoucherController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailVoucherController") as! DetailVoucherController
            detailVoucherController.voucherData = voucherList[indexpath.row]
            self.navigationController?.pushViewController(detailVoucherController, animated: true)
        }
    }
    
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
}
