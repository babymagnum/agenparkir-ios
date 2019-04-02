//
//  VenueTicketModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 28/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

class VenueTicketModel {
    var name_building: String?
    var address: String?
    var images_building: String?
    var count_event: Int?
    var ticketing = [TicketModel]()
    
    init(_ name_building: String, _ address: String, _ images_building: String, _ count_event: Int, _ ticketing: [TicketModel]) {
        self.name_building = name_building
        self.address = address
        self.images_building = images_building
        self.count_event = count_event
        self.ticketing = ticketing
    }
}
