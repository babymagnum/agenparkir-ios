//
//  DetailVoucherController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 10/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class DetailVoucherController: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    @IBOutlet weak var iconCoinsTop: UIImageView!
    @IBOutlet weak var viewCoinTop: UIView!
    @IBOutlet weak var viewCoinWidthTop: NSLayoutConstraint!
    @IBOutlet weak var amountCoinTop: UILabel!
    @IBOutlet weak var iconClose: UIImageView!
    @IBOutlet weak var imageVoucher: UIImageView!
    @IBOutlet weak var viewCoinVoucher: UIView!
    @IBOutlet weak var amountCoinVoucher: UILabel!
    @IBOutlet weak var viewCoinVoucherWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonBuy: UIButton!
    @IBOutlet weak var voucherName: UILabel!
    @IBOutlet weak var voucherRequirements: UILabel!
    @IBOutlet weak var voucherValue: UILabel!
    @IBOutlet weak var iconCoinsPrice: UIImageView!
    
    //MARK: Props
    var myCoins: Int?
    var popRecognizer: InteractivePopRecognizer?
    var voucherData: VoucherModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInteractiveRecognizer()
        
        customView()
        
        populateDefaultData()
        
        getMyCoins()
        
        handleEvent()
    }
    
    private func populateDefaultData(){
        if let data = voucherData {
            let approximateTextWidth = self.amountCoinVoucher.frame.width - 10 - 10
            let size = CGSize(width: approximateTextWidth, height: 100)
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
            let estimatedFrame = NSString(string: "\(data.coin_price ?? 0)").boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.viewCoinVoucherWidth.constant = self.iconCoinsPrice.frame.width + estimatedFrame.width + 2.5 + 25
                self.view.layoutIfNeeded()
            })
            
            self.amountCoinVoucher.text = "\(data.coin_price ?? 0)"
            
            if data.voucher_images.count == 0 {
                self.imageVoucher.image = UIImage(named: "Artboard 12@0.75x-8")
            } else { self.imageVoucher.loadUrl("\(StaticVar.root_images)\(data.voucher_images[0].images ?? "")") }
            
            voucherName.text = data.name
            voucherValue.text = "Nilai Voucher - Rp \(PublicFunction.instance.prettyRupiah("\(data.value ?? 0)"))"
            voucherRequirements.text = "- Coin yang dibutuhkan sebanyak \(data.coin_price ?? 0) \n- Setelah voucher berhasil dibeli, nilai voucher akan langsung masuk kedalam saldo My Card anda"
            
            let requirementHeight = self.voucherRequirements.frame.height + 20
            let requirementsSize = CGSize(width: UIScreen.main.bounds.width, height: requirementHeight)
            let requirementsAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
            let requirementsEstimatedFrame = NSString(string: "\(voucherRequirements.text ?? "")").boundingRect(with: requirementsSize, options: .usesLineFragmentOrigin, attributes: requirementsAttributes, context: nil)
            
            UIView.animate(withDuration: 0.2) {
                self.contentMainHeight.constant += requirementsEstimatedFrame.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func handleEvent() {
        buttonBuy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonBuyClick)))
        iconClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconCloseClick)))
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func getMyCoins(){
        Networking.instance.getCoins(customer_id: UserDefaults.standard.string(forKey: StaticVar.id)!) { (coins, customer_id, error) in
            DispatchQueue.main.async {
                if let _ = error { return }
                
                let approximateTextWidth = self.amountCoinTop.frame.width - 10 - 10
                let size = CGSize(width: approximateTextWidth, height: 100)
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
                let estimatedFrame = NSString(string: "\(coins ?? 0)").boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewCoinWidthTop.constant = self.iconCoinsTop.frame.width + estimatedFrame.width + 2.5 + 25
                    self.view.layoutIfNeeded()
                })
                
                self.amountCoinTop.text = "\(coins ?? 0)"
                
                self.myCoins = coins
            }
        }
    }
    
    private func customView() {
        iconClose.image = UIImage(named: "Artboard 230@0.75x-8")?.tinted(with: UIColor(rgb: 0xFB8C00))
        viewCoinTop.layer.cornerRadius = viewCoinTop.frame.height / 2
        viewCoinVoucher.layer.cornerRadius = viewCoinVoucher.frame.height / 2
        buttonBuy.layer.cornerRadius = buttonBuy.frame.height / 2
        imageVoucher.clipsToBounds = true
        imageVoucher.layer.cornerRadius = 10
    }
}

//MARK: Handle event
extension DetailVoucherController {
    @objc func iconCloseClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func buttonBuyClick() {
        guard let voucher = voucherData else { return }
        
        if self.myCoins! >= voucher.coin_price! {
            Networking.instance.buyCoins(voucherId: "\(voucher.id ?? 0)") { (message, error) in
                if let error = error {
                    PublicFunction.instance.showUnderstandDialog(self, "Failed Buy Voucher", error, "Understand")
                    return
                }
                
                PublicFunction.instance.showUnderstandDialog(self, "Success Buy Voucher", "Pembelian voucher berhasil, anda bisa melihat saldo my card anda bertambah sesuai dengan nilai di voucher ini", "Understand")
            }
        } else {
            //tidak diijinkan
            PublicFunction.instance.showUnderstandDialog(self, "Cant Buy Voucher", "Your my coins amount is not enought to buy this voucher", "Understand")
        }
    }
}
