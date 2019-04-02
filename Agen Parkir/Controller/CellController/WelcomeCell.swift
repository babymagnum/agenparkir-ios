//
//  WelcomeCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class WelcomeCell: UICollectionViewCell {
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var dot1: UIView!
    @IBOutlet weak var dot2: UIView!
    @IBOutlet weak var dot3: UIView!
    @IBOutlet weak var dot4: UIView!
    @IBOutlet weak var dot5: UIView!
    
    override func awakeFromNib() {
        //create circle view
        dot1.layer.cornerRadius = dot1.frame.width / 2
        dot2.layer.cornerRadius = dot2.frame.width / 2
        dot3.layer.cornerRadius = dot3.frame.width / 2
        dot4.layer.cornerRadius = dot4.frame.width / 2
        dot5.layer.cornerRadius = dot5.frame.width / 2
        
        //create circle image header
        imageHeader.clipsToBounds = false
        imageHeader.layer.cornerRadius = imageHeader.frame.width / 2
    }
    
    var welcomeModel: WelcomeModel? {
        didSet {
            if let data = welcomeModel {
                imageHeader.image = UIImage(named: data.imageHeader!)
                title.text = data.title
                message.text = data.message
                self.highlightDot(index: data.selectedPage!)
            }
        }
    }
    
    //func to change the dot dynamically
    func highlightDot(index: Int) {
        switch index {
        case 0:
            dot1.backgroundColor = UIColor(rgb: 0x4552FF)
            dot2.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot3.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot4.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot5.backgroundColor = UIColor(rgb: 0xBFBFBF)
            skipButton.isHidden = false
            nextButton.setTitle("Next", for: .normal)
            
        case 1:
            dot1.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot2.backgroundColor = UIColor(rgb: 0x4552FF)
            dot3.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot4.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot5.backgroundColor = UIColor(rgb: 0xBFBFBF)
            skipButton.isHidden = false
            nextButton.setTitle("Next", for: .normal)
        case 2:
            dot1.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot2.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot3.backgroundColor = UIColor(rgb: 0x4552FF)
            dot4.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot5.backgroundColor = UIColor(rgb: 0xBFBFBF)
            skipButton.isHidden = false
            nextButton.setTitle("Next", for: .normal)
        case 3:
            dot1.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot2.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot3.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot4.backgroundColor = UIColor(rgb: 0x4552FF)
            dot5.backgroundColor = UIColor(rgb: 0xBFBFBF)
            skipButton.isHidden = false
            nextButton.setTitle("Next", for: .normal)
        default:
            dot1.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot2.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot3.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot4.backgroundColor = UIColor(rgb: 0xBFBFBF)
            dot5.backgroundColor = UIColor(rgb: 0x4552FF)
            skipButton.isHidden = true
            nextButton.setTitle("Done", for: .normal)
        }
    }
}
