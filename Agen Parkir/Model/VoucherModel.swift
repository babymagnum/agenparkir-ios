//
//  VoucherModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 10/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct VoucherModel: Decodable {
    var id: Int?
    var name: String?
    var code: String?
    var value: Int?
    var coin_price: Int?
    var voucher_images = [VoucherImagesModel]()
    var description: String?
}
