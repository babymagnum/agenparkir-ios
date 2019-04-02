//
//  RegisterModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 27/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct RegisterModel {
    let fullName: String?
    let email: String?
    let password: String?
    let phone: String?
    
    init(fullName: String, email: String, password: String, phone: String) {
        self.fullName = fullName
        self.email = email
        self.password = password
        self.phone = phone
    }
}
