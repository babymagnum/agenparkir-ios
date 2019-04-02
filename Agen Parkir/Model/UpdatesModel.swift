//
//  UpdatesModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 04/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct UpdatesModel {
    var venueName: String?
    var motorCount: Int?
    var carCount: Int?
    var lastUpdate: String?
    var index: String?
    
    init(_ venueName: String, _ motorCount: Int, _ carCount: Int, _ lastUpdate: String, _ index: String) {
        self.venueName = venueName
        self.motorCount = motorCount
        self.carCount = carCount
        self.lastUpdate = lastUpdate
        self.index = index
    }
}
