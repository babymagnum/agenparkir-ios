//
//  RecentlyModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 01/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

enum RecentlyState {
    case active, inactive, pending1, pending2
}

struct RecentlyModel {
    let venueName: String?
    let image: String?
    let orderDate: String?
    let building_id: Int?
    
    init(venueName: String, image: String, orderDate: String, building_id: Int) {
        self.venueName = venueName
        self.image = image
        self.orderDate = orderDate
        self.building_id = building_id
    }
}
