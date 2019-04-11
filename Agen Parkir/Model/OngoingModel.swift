//
//  OngoingModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 12/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct OngoingModel {
    var building_name: String?
    var booking_start_time: String?
    var order_id: Int?
    var plate_number: String?
    var name_customers: String?
    var booking_status_id: Int?
    var payment_status: Int?
    var isNonCash: Int?
    var latitude: String?
    var longitude: String?
    var booking_code: String?
    var vehicle_type: Int?
    var removeTimer: Bool?
    var officer: [String]?
}
