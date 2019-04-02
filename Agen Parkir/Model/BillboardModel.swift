//
//  BillboardModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 02/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct BillboardModel {
    let image: String?
    let id: Int?
    
    init(image: String, id: Int) {
        self.image = image
        self.id = id
    }
}
