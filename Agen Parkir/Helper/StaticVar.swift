//
//  StaticVar.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 28/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

struct StaticVar {
    static let login = "login"
    static let email = "email"
    static let applicationState = "applicationState"
    static let token = "token"
    static let id = "id"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let hasAccount = "hasAccount"
    static let name = "name"
    static let phone = "phone"
    static let images = "images"
    static let sendbirdIdentifier = "sendbirdIdentifier"
    static let my_card = "my_card"
    static let onesignal_player_id = "onesignal_player_id"
    static let root_images = ""
    static let last_timer = "last_timer"
    static let time_timer_removed = "time_timer_removed"
    static let reload_home_controller = "reload_home_controller"
    static let parking_lot = "parking_lot"
    static let last_total_price = "last_total_price"
    static let last_vehicle_type = "last_vehicle_type"
    static let last_parking_type = "last_parking_type"
    static let last_place_type = "last_place_type"
    static let last_payment_type = "last_payment_type"
    static let userMessage = "userMessage"
    static let fileMessage = "fileMessage"
    
    //user default
    static let getApplicationState = UserDefaults.standard.string(forKey: StaticVar.applicationState)    
}

enum FormState {
    case allow, dont
}
