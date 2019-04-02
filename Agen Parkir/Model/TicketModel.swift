//
//  TicketModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 18/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct TicketModel {
    var tickets_id: Int?
    var images: String?
    var schedule: String?
    var name: String?
    var price: Int?
    var quantity: Int?
    var limit_ticket: Int?
    var limit_ticket_to: Int?
    var buildings_id: Int?
    var reedem_date: String?
    var building_name: String?
}
