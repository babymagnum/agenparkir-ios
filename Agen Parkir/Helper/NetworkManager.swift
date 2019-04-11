//
//  NetworkManager.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 10/04/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    init() {
        manager = NetworkReachabilityManager(host: "google.com")
        listenForReachability()
    }
    
    private let manager: NetworkReachabilityManager?
    private var reachable: Bool = false
    private func listenForReachability() {
        self.manager?.listener = { [unowned self] status in
            switch status {
            case .notReachable:
                self.reachable = false
            case .reachable(_), .unknown:
                self.reachable = true
            }
        }
        self.manager?.startListening()
    }
    
    func isConnected() -> Bool {
        return reachable
    }
}
