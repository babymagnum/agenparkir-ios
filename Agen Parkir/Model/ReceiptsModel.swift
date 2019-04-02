//
//  ReceiptsModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 14/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct ReceiptsModel {
    var orders_id: Int?
    var booking_status_id: Int?
    var booking_code: String?
    var payment_types: Int?
    var booking_tax: Any?
    var booking_sub_total: Int?
    var booking_total: Int?
    var vouchers_nominal: Int?
    var customers_name: String?
    var customers_images: String?
    var building_name: String?
    var booking_start_time: String?
    var parking_lot: String?
    var plate_number: String?
    var parking_types: Int?
    var vehicle_types: Int?
}
