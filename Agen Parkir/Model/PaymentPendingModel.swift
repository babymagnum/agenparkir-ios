//
//  PaymentPendingModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 27/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct PaymentPendingModel {
    var orders_id: Int?
    var payment_status: Int?
    var total: String?
    var booking_code: String?
    var created_at: String?
    var payment_types: String?
    var bank_name: String?
    var virtual_account: String?
    var expired_time: String?
}
