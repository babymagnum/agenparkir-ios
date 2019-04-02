//
//  StoreDetailModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct StoreDetailModel {
    var store_name: String?
    var store_description: String?
    var store_images: String?
    var buildings_address: String?
    var time: String?
    var products = [ProductModel]()
}
