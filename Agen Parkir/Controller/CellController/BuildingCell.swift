//
//  BookingCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 09/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

protocol BuildingCellProtocol {
    func viewClick(_ content: String, _ data: (building_id: String, address: String, building_name: String))
}

class BuildingCell: UICollectionViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var textParkingService: UIButton!
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var icon4: UIImageView!
    @IBOutlet weak var carsAvailable: UILabel!
    @IBOutlet weak var motorcycleAvailable: UILabel!
    @IBOutlet weak var iconCars: UIImageView!
    @IBOutlet weak var iconMotorcycle: UIImageView!
    @IBOutlet weak var actionCollectionView: UICollectionView!
    
    var listAction = [String]()
    var delegate: BuildingCellProtocol?
    
    override func awakeFromNib() {
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = 7
        textParkingService.clipsToBounds = true
        textParkingService.layer.cornerRadius = textParkingService.frame.height / 2
        
        initCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.6
        
        DispatchQueue.main.async {
            self.actionCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    var buildingData: BuildingModel? {
        didSet {
            if let data = buildingData {
                let url = "\(StaticVar.root_images)\(data.images!)"
                imageHeader.loadUrl(url)
                venueName.text = data.name_building
                motorcycleAvailable.text = "\(data.motor ?? 0)"
                carsAvailable.text = "\(data.mobil ?? 0)"
                self.checkParkState(data)
                self.loadAction(data)
            }
        }
    }
    
    private func initCollectionView() {
        actionCollectionView.backgroundColor = UIColor(rgb: 0xffffff).withAlphaComponent(0)
        actionCollectionView.delegate = self
        actionCollectionView.dataSource = self
        actionCollectionView.isPrefetchingEnabled = false
        actionCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func loadAction(_ data: BuildingModel){
        self.listAction.removeAll()
        
        self.listAction.append("Book Parking")
        
        if data.has_ticketing == 1 {
            self.listAction.append("Buy Ticket")
        }
        
        if data.has_store == 1 {
            self.listAction.append("Visit Store")
        }
        
        self.actionCollectionView.reloadData()
    }
    
    private func checkParkState(_ building: BuildingModel){
        if building.has_motor == 0 {
            iconMotorcycle.image = UIImage(named: "Artboard 149@0.75x-8")
            motorcycleAvailable.text = "Not Available"
            motorcycleAvailable.textColor = UIColor.lightGray
        } else if building.motor == 0 {
            iconMotorcycle.image = UIImage(named: "Artboard 140@0.75x-8")
            motorcycleAvailable.text = "Full"
            motorcycleAvailable.textColor = UIColor(rgb: 0xd50000)
        } else if building.motor! < 20 {
            iconMotorcycle.image = UIImage(named: "Artboard 172@0.75x-8")
            motorcycleAvailable.textColor = UIColor(rgb: 0xd50000)
        } else {
            iconMotorcycle.image = UIImage(named: "Artboard 122@0.75x-8")
            motorcycleAvailable.text = "\(building.motor ?? 0)"
            motorcycleAvailable.textColor = UIColor(rgb: 0x00A551)
        }
        
        if building.has_mobil == 0 {
            iconCars.image = UIImage(named: "Artboard 148@0.75x-8")
            carsAvailable.text = "Not Available"
            carsAvailable.textColor = UIColor.lightGray
        } else if building.mobil == 0 {
            iconCars.image = UIImage(named: "Artboard 139@0.75x-8")
            carsAvailable.text = "Full"
            carsAvailable.textColor = UIColor(rgb: 0xd50000)
        } else if building.mobil! < 20 {
            iconCars.image = UIImage(named: "Artboard 171@0.75x-8")
            carsAvailable.textColor = UIColor(rgb: 0xd50000)
        } else {
            iconCars.image = UIImage(named: "Artboard 15@0.75x-8")
            carsAvailable.text = "\(building.mobil ?? 0)"
            carsAvailable.textColor = UIColor(rgb: 0x00A551)
        }
        
        if building.has_valet == 0 {
            icon1.image = UIImage(named: "Artboard 150@0.75x-8")
        } else {
            icon1.image = UIImage(named: "Artboard 132@0.75x-8")
        }
        
        if building.has_standard == 0 {
            icon2.image = UIImage(named: "Artboard 151@0.75x-8")
        } else {
            icon2.image = UIImage(named: "Artboard 133@0.75x-8")
        }
        
        if building.has_indoor == 0 {
            icon3.image = UIImage(named: "Artboard 152@0.75x-8")
        } else {
            icon3.image = UIImage(named: "Artboard 134@0.75x-8")
        }
        
        if building.has_outdoor == 0 {
            icon4.image = UIImage(named: "Artboard 153@0.75x-8")
        } else {
            icon4.image = UIImage(named: "Artboard 135@0.75x-8")
        }
    }
}

extension BuildingCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuildingActionCell", for: indexPath) as! BuildingActionCell
        
        let approximateTextWidth = cell.actionLabel.frame.width
        let size = CGSize(width: approximateTextWidth, height: cell.actionLabel.frame.height)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
        let estimatedFrame = NSString(string: listAction[indexPath.item]).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return CGSize(width: cell.iconBooking.frame.width + 37 + estimatedFrame.width, height: cell.contentMain.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listAction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuildingActionCell", for: indexPath) as! BuildingActionCell
        cell.actionData = listAction[indexPath.item]
        cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentMainActionClick(sender:))))
        return cell
    }
}

extension BuildingCell {
    @objc func contentMainActionClick(sender: UITapGestureRecognizer){
        if let indexpath = actionCollectionView.indexPathForItem(at: sender.location(in: actionCollectionView)){
            //delegate?.viewClick(listAction[indexpath.item], (buildingData?.building_id)!)
            delegate?.viewClick(listAction[indexpath.item], (building_id: "\(buildingData?.building_id ?? 0)", address: buildingData?.address ?? "", building_name: buildingData?.name_building ?? ""))
        }
    }
}
