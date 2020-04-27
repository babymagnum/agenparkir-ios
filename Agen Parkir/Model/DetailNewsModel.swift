//
//  DetailNewsModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 27/04/20.
//  Copyright © 2020 Mika. All rights reserved.
//

import Foundation

struct DetailNews: Decodable {
    var data = [DetailsNewsItem]()
}

struct DetailsNewsItem: Decodable {
    var id: Int?
    var title: String?
    var content: String?
    var created_at: String?
}
