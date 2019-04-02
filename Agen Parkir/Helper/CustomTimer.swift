//
//  RepeatingTimer.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 13/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation

class CustomTimer: Timer {
    
    static var sharedTimers: [CustomTimer] = []
    
    static func invalidateAllTimers() {
        for timer in CustomTimer.sharedTimers {
            timer.invalidate()
        }
    }
    
    // Use appropriate initializer and super calls.
    convenience init() {
        self.init()
        CustomTimer.sharedTimers.append(self)
    }
    
    deinit {
        CustomTimer.sharedTimers.removeAll { (timer) -> Bool in
            return timer === self
        }
    }
}
