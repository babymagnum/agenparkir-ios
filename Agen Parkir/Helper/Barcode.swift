//
//  Barcode.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 22/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation
import UIKit

class Barcode {
    class func fromString(string : String) -> UIImage? {
        let data = string.data(using: .ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let outputCIImage = filter.outputImage {
                return UIImage(ciImage: outputCIImage)
            }
        }
        return nil
    }
}
