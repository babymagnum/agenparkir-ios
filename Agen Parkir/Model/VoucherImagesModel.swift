//
//  VoucherImagesModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 10/05/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct VoucherImagesModel: Decodable {
    var id: Int?
    var images: String?
    var sizes: Int?
    var vouchers_id: Int?
}
