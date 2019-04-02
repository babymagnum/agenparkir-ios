//
//  SettingsModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 06/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct SettingsModel {
    var icon: String?
    var label: String?
    var id: Int?
    
    init(_ icon: String, _ label: String, _ id: Int) {
        self.icon = icon
        self.label = label
        self.id = id
    }
}
