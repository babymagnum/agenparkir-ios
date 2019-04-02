//
//  ServicesModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 04/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct ServicesModel {
    var image: String?
    var title: String?
    var description: String?
    var date: String?
    
    init(_ image: String, _ title: String, _ description: String, _ date: String) {
        self.image = image
        self.title = title
        self.description = description
        self.date = date
    }
}
