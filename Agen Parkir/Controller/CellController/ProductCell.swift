//
//  ProductCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    //MARK: Outlet
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    override func awakeFromNib() {
        image.clipsToBounds = true
        image.layer.cornerRadius = 5
    }
    
    var dataProducts: ProductModel? {
        didSet {
            if let data = dataProducts {
                //image.loadUrl("\(StaticVar.root_images)\(data.product_images ?? "")")
                image.kf.setImage(with: URL(string: "\(StaticVar.root_images)\(data.product_images ?? "")"), placeholder: UIImage(named: "Artboard 243@54x-8"))
                name.text = data.product_name
                price.text = "\(PublicFunction().prettyRupiah("\(data.product_price ?? 0)"))"
                productDescription.text = data.product_description
            }
        }
    }
}
