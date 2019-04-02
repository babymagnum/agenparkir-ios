//
//  CurrentModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 05/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct CurrentModel {
    var id: Int?
    var name: String?
    var email: String?
    var phone: Int?
    var images: String?
    var my_card: String?
    
    init(_ id: Int, _ name: String, _ email: String, _ phone: Int, _ images: String, _ my_card: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.images = images
        self.my_card = my_card
    }
    
    func getMyCard() -> String {
        return "Rp,\(PublicFunction().prettyRupiah("\(self.my_card!.dropLast(3))"))"
    }
}
