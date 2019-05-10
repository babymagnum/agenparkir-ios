//
//  DataModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 06/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct DataCoins: Decodable {
    let data: CoinsModel
}

struct DataVouchers: Decodable {
    let data: [VoucherModel]
}
