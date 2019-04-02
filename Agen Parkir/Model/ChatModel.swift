//
//  ChatModel.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 30/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

enum TypeMessage {
    case text, image
}

struct ChatModel {
    var id: Int64?
    var message: String?
    var createdAt: Int64?
    var sender: String?
    var typeMessage: TypeMessage?
    
    init(_ id: Int64, _ message: String, _ createdAt: Int64, _ sender: String, _ typeMessage: TypeMessage) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.sender = sender
        self.typeMessage = typeMessage
    }
}
