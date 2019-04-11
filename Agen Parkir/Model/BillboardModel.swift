//
//  BillboardModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 02/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct BillboardModel {
    let images: String?
    let store_id: Int?
    let description: String?
    let buildings_id: Int?
    let time: String?
    let address: String?
    let name_store: String?
    
    init(images: String, store_id: Int, description: String, buildings_id: Int, time: String, address: String, name_store: String) {
        self.images = images
        self.store_id = store_id
        self.description = description
        self.buildings_id = buildings_id
        self.time = time
        self.address = address
        self.name_store = name_store
    }
}
