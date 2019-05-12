//
//  Networking.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 06/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class Networking: NSObject {

    static let instance = Networking()
    var base_url: String?
    
    override init() {
        base_url = UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" ? "https://dev46.agenparkir.com/" : "https://agenparkir.com/"
    }

    func getCoins(customer_id: String, completion: @escaping (_ coins: Int?, _ customer_id: String?, _ error: String?) -> Void) {
        guard let url = URL(string: "\(base_url ?? "")api/android/customer-coins?customers_id=\(customer_id)") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, e) in
            if let error = e {
                completion(nil, nil, error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let dataCoins = try JSONDecoder().decode(DataCoins.self, from: data)
                
                completion(dataCoins.data.coins ?? 0, dataCoins.data.customers_id ?? "", nil)
            } catch let err {
                print(err)
            }
            
        }.resume()
    }
    
    func buyCoins(voucherId: String, completionHandler: @escaping(_ message: String?, _ error: String?) -> Void){
        guard let url = URL(string: "\(base_url ?? "")api/android/customer-coins-corversion") else { return }
        
        let param: [String : String] = [
            "vouchers_id": voucherId,
            "customers_id": UserDefaults.standard.string(forKey: StaticVar.id)!
        ]
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { (response) in
            switch response.result {
            case .success(let responseSuccess):
                let data = JSON(responseSuccess)
                
                print("data buy coins \(data)")
                
                if data["status"].string == "error" {
                    completionHandler(nil, data["message"].string)
                    return
                }
                
                completionHandler("Success buy voucher", nil)
                
            case .failure(let responseError):
                completionHandler(nil, responseError.localizedDescription)
            }
        }
    }
    
    func getVoucherList(completion: @escaping(_ voucherList: [VoucherModel]?, _ error: String?) -> Void) {
        guard let url = URL(string: "\(base_url ?? "")api/android/vouchers-list") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                completion(nil, "error")
                return
            }
            
            do {
                let dataVoucher = try JSONDecoder().decode(DataVouchers.self, from: data)
                completion(dataVoucher.data, nil)
            } catch let err { completion(nil, err.localizedDescription) }
            
            }.resume()
    }
    
    func convertCoins(vouchers_id: String, customers_id: String) {
        let url = "\(base_url ?? "")api/android/customer-coins-corversion"
        
        let params = [
            "vouchers_id": vouchers_id,
            "customers_id": customers_id
        ]
        
        Alamofire.request(url, method: .post, parameters: params).responseJSON { (response) in
            
        }
    }
}
