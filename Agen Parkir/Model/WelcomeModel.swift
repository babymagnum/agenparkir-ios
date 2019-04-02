//
//  WelcomeModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct WelcomeModel {
    var imageHeader: String?
    var title: String?
    var message: String?
    var selectedPage: Int?
    
    init(imageHeader: String, title: String, message: String, selectedPage: Int) {
        self.imageHeader = imageHeader
        self.title = title
        self.message = message
        self.selectedPage = selectedPage
    }
}
