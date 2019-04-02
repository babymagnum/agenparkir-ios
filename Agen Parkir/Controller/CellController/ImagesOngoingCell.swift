//
//  ImagesOngoingCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 14/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class ImagesOngoingCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    var imageData: String? {
        didSet{
            if let data = imageData{
                image.loadUrl("\(StaticVar.root_images)\(data)")
            } else {
                image.image = UIImage(named: "Artboard 9@0.75x-8")
            }
        }
    }
}
