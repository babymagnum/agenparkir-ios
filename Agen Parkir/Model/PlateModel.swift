//
//  PlateModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 07/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct PlateModel {
    let plate_id: Int!
    let vehicle_id: Int!
    let number_plate: String!
    let title_plate: String!
    
    init(_ plate_id: Int, _ vehicle_id: Int, _ number_plate: String, _ title_plate: String) {
        self.plate_id = plate_id
        self.vehicle_id = vehicle_id
        self.number_plate = number_plate
        self.title_plate = title_plate
    }
}
