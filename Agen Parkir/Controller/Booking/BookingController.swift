//
//  BookingController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 09/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class BookingController: BaseViewController, UICollectionViewDelegate {

    //MARK: Outlet
    @IBOutlet weak var viewContentPickVehicle: UIView!
    @IBOutlet weak var iconPickVehicle: UIImageView!
    @IBOutlet weak var iconCancelVehicle: UIImageView!
    @IBOutlet weak var viewCancelVehicle: UIView!
    @IBOutlet weak var pickedVehicle: UILabel!
    @IBOutlet weak var viewPlateController: UIView!
    @IBOutlet weak var plateCollectionView: UICollectionView!
    @IBOutlet weak var iconCancelBooking: UIImageView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var viewCars: UIView!
    @IBOutlet weak var viewMotor: UIView!
    @IBOutlet weak var iconCars: UIImageView!
    @IBOutlet weak var textCars: UILabel!
    @IBOutlet weak var iconMotor: UIImageView!
    @IBOutlet weak var textMotor: UILabel!
    @IBOutlet weak var textSelectedVehicle: UIButton!
    @IBOutlet weak var viewVallet: UIView!
    @IBOutlet weak var iconVallet: UIImageView!
    @IBOutlet weak var textVallet: UILabel!
    @IBOutlet weak var viewStandart: UIView!
    @IBOutlet weak var iconStandart: UIImageView!
    @IBOutlet weak var textStandart: UILabel!
    @IBOutlet weak var viewIndoor: UIView!
    @IBOutlet weak var iconIndoor: UIImageView!
    @IBOutlet weak var textIndoor: UILabel!
    @IBOutlet weak var viewOutdoor: UIView!
    @IBOutlet weak var iconOutdoor: UIImageView!
    @IBOutlet weak var textOutdoor: UILabel!
    @IBOutlet weak var viewCreditDebit: UIView!
    @IBOutlet weak var iconCreditDebit: UIImageView!
    @IBOutlet weak var textCreditDebit: UILabel!
    @IBOutlet weak var viewCash: UIView!
    @IBOutlet weak var iconCash: UIImageView!
    @IBOutlet weak var textCash: UILabel!
    @IBOutlet weak var viewMycard: UIView!
    @IBOutlet weak var iconMycard: UIImageView!
    @IBOutlet weak var textMycard: UILabel!
    @IBOutlet weak var buttonOrder: UIButton!
    @IBOutlet weak var viewVenueName: UIView!
    @IBOutlet weak var buttonAddPlate: UIButton!
    @IBOutlet weak var viewPickVehicle: UIView!
    
    //MARK: Props
    var listPlate = [PlateModel]()
    let operation = OperationQueue()
    var vehicleType: Int?
    var placeType: String?
    var parkingType: Int?
    var paymentType: Int?
    let bag = DisposeBag()
    var buildingModel: BuildingModel?
    var building_id: Int?
    
    //form
    var formState = FormState.dont
    var pickVehicleType = BehaviorRelay(value: false)
    var myVehicle = BehaviorRelay(value: false)
    var pickParkingType = BehaviorRelay(value: false)
    var pickParkingPlace = BehaviorRelay(value: false)
    var pickParkingPayment = BehaviorRelay(value: false)
    var popRecognizer: InteractivePopRecognizer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()
        
        initCollectionView()
        
        customView()
        
        handleGesture()
        
        loadDetailVenue()
        
        bindUI()
    }
    
    private func bindUI() {
        Observable.combineLatest(pickVehicleType.asObservable(), myVehicle.asObservable(), pickParkingType.asObservable(), pickParkingPlace.asObservable(), pickParkingPayment.asObservable(), resultSelector: {vehicleType, vehicle, parkingType, parkingPlace, parkingPayment in
            
            if vehicleType && vehicle && parkingType && parkingPlace && parkingPayment {
                self.buttonOrder.backgroundColor = UIColor(rgb: 0x00A551)
                self.formState = .allow
            } else {
                self.buttonOrder.backgroundColor = UIColor.lightGray
                self.formState = .dont
            }
            
        }).subscribe().disposed(by: bag)
    }
    
    private func updateUI(_ building: BuildingModel) {
        DispatchQueue.main.async {
            if building.has_motor == 0 {
                self.iconMotor.image = UIImage(named: "Artboard 149@0.75x-8")
                self.customNotAvailabelText("Motorcycle", "(Not Available)", self.textMotor)
                self.viewMotor.isUserInteractionEnabled = false
            } else if building.motor == 0 {
                self.iconMotor.image = UIImage(named: "Artboard 140@0.75x-8")
                self.customNotAvailabelText("Motorcycle", "(Full)", self.textMotor)
                self.viewMotor.isUserInteractionEnabled = false
            }
            
            if building.has_mobil == 0 {
                self.iconCars.image = UIImage(named: "Artboard 148@0.75x-8")
                self.customNotAvailabelText("Cars", "(Not Available)", self.textCars)
                self.viewCars.isUserInteractionEnabled = false
            } else if building.mobil == 0 {
                self.iconCars.image = UIImage(named: "Artboard 139@0.75x-8")
                self.customNotAvailabelText("Cars", "(Full)", self.textCars)
                self.viewCars.isUserInteractionEnabled = false
            }
            
            if building.has_valet == 0 {
                self.iconVallet.image = UIImage(named: "Artboard 150@0.75x-8")
                self.customNotAvailabelText("Valet", "(Not Available)", self.textVallet)
                self.viewVallet.isUserInteractionEnabled = false
            }
            
            if building.has_standard == 0 {
                self.iconStandart.image = UIImage(named: "Artboard 151@0.75x-8")
                self.customNotAvailabelText("Standart", "(Not Available)", self.textStandart)
                self.viewStandart.isUserInteractionEnabled = false
            }
            
            if building.has_indoor == 0 {
                self.iconIndoor.image = UIImage(named: "Artboard 152@0.75x-8")
                self.customNotAvailabelText("Indoor", "(Not Available)", self.textIndoor)
                self.viewIndoor.isUserInteractionEnabled = false
            }
            
            if building.has_outdoor == 0 {
                self.iconOutdoor.image = UIImage(named: "Artboard 153@0.75x-8")
                self.customNotAvailabelText("Outdoor", "(Not Available)", self.textOutdoor)
                self.viewOutdoor.isUserInteractionEnabled = false
            }
            
            self.venueName.text = building.name_building
        }
    }
    
    private func customNotAvailabelText(_ content: String, _ addedText: String, _ label: UILabel) {
        let mainString = "\(content) \r\n\(addedText)"
        let editedText = "(\(addedText))"
        let editedString = NSMutableAttributedString(string: mainString)
        let editedTextSize = UIFont.systemFont(ofSize: 12)
        editedString.addAttribute(kCTFontAttributeName as NSMutableAttributedString.Key, value: editedTextSize, range: NSMakeRange(mainString.count - editedText.count, editedText.count))
        label.attributedText = editedString
        label.textColor = UIColor.lightGray
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func loadDetailVenue() {
        SVProgressHUD.show()
        
        let detailBuildingOperation = DetailBuildingOperation(buildingId: building_id!)
        operation.addOperation(detailBuildingOperation)
        detailBuildingOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch detailBuildingOperation.state {
                case .success?:
                    if let building = detailBuildingOperation.buildingModel {
                        self.buildingModel = building
                        self.updateUI(building)
                    }
                case .error?:
                    if let err = detailBuildingOperation.error {
                        PublicFunction.instance.showUnderstandDialog(self, "Error", err, "Understand")
                    }
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", "Operation is canceled by system, please try again", "Understand")
                }
            }
        }
    }
    
    private func handleGesture() {
        iconCancelBooking.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconCancelBookingClick)))
        textSelectedVehicle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textSelectedVehicleClick)))
        viewCancelVehicle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCancelVehicleClick)))
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        buttonAddPlate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonAddPlateClick)))
        viewPickVehicle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPickVehicleClick)))
        viewCars.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCarsClick)))
        viewMotor.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMotorClick)))
        viewVallet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewValletClick)))
        viewStandart.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewStandartClick)))
        viewIndoor.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewIndoorClick)))
        viewOutdoor.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewOutdoorClick)))
        viewCreditDebit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCreditDebitClick)))
        viewCash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCashClick)))
        viewMycard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMycardClick)))
        buttonOrder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonOrderClick)))
        viewPlateController.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPlateControllerClick)))
    }
    
    private func initCollectionView() {
        plateCollectionView.delegate = self
        plateCollectionView.dataSource = self
        plateCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func customView() {
        viewVenueName.layer.cornerRadius = viewVenueName.frame.height / 2
        textSelectedVehicle.clipsToBounds = true
        textSelectedVehicle.layer.cornerRadius = 5
        textSelectedVehicle.layer.borderWidth = 1
        textSelectedVehicle.layer.borderColor = UIColor.lightGray.cgColor
        buttonOrder.clipsToBounds = true
        buttonOrder.layer.cornerRadius = buttonOrder.frame.height / 2
        viewCancelVehicle.layer.cornerRadius = viewCancelVehicle.frame.width / 2
        viewPickVehicle.layer.cornerRadius = viewPickVehicle.frame.width / 2
        PublicFunction.instance.changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
        PublicFunction.instance.changeTintColor(imageView: iconPickVehicle, hexCode: 0x00A551, alpha: 1.0)
        PublicFunction.instance.changeTintColor(imageView: iconCancelVehicle, hexCode: 0xd50000, alpha: 1.0)
    }
    
    private func loadPlate() {
        let showListPlateOperation = ShowListPlateOperation()
        operation.addOperation(showListPlateOperation)
        showListPlateOperation.completionBlock = {
            DispatchQueue.main.async {
                switch showListPlateOperation.state {
                case .success?:
                    self.listPlate.removeAll()
                    
                    for (index, plate) in showListPlateOperation.listPlate.enumerated() {
                        if plate.vehicle_id == self.vehicleType {
                            self.listPlate.append(plate)
                        }
                        
                        if index == showListPlateOperation.listPlate.count - 1 {
                            DispatchQueue.main.async {
                                self.plateCollectionView.reloadData()
                                
                                if self.listPlate.count == 0 {
                                    self.buttonAddPlate.isHidden = false
                                } else {
                                    self.buttonAddPlate.isHidden = true
                                }
                            }
                        }
                    }
                case .error?:
                    PublicFunction.instance.showUnderstandDialog(self, "Error Get List Plate", showListPlateOperation.error!, "Understand")
                    self.buttonAddPlate.isHidden = false
                case .empty?:
                    DispatchQueue.main.async {
                        self.buttonAddPlate.isHidden = false
                    }
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error!", "Please click the retry button to refresh data", "Understand")
                }
            }
        }
    }
    
    private func changeToGreen(_ image: UIImageView, _ image_file: String, _ label: UILabel) {
        image.image = UIImage(named: image_file)
        label.textColor = UIColor(rgb: 0x00A551)
    }

    private func changeToDefault(_ image: UIImageView, _ image_file: String, _ label: UILabel) {
        image.image = UIImage(named: image_file)
        label.textColor = UIColor.darkGray
    }
    
    private func booking(_ building: BuildingModel) {
        SVProgressHUD.show()
        
        let bookingOperation = BookingOperation(bookingData: (building_id: "\(building.building_id ?? 999)", parking_types: "\(parkingType ?? 1)", vehicle_types: "\(vehicleType ?? 1)", voucher_id: "", type: placeType!, plate: textSelectedVehicle.title(for: .normal)!, payment_type_id: "\(paymentType ?? 1)"))
        
        operation.addOperation(bookingOperation)
        
        bookingOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch bookingOperation.state {
                case .success?:
                    DispatchQueue.main.async {
                        let bookingAgreementController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookingAgreementController") as! BookingAgreementController
                        bookingAgreementController.dataBooking = (vehicleType: self.vehicleType, parkingType: self.parkingType, placeType: self.placeType, paymentType: self.paymentType) as? (vehicleType: Int, parkingType: Int, placeType: String, paymentType: Int)
                        bookingAgreementController.returnBookingData = bookingOperation.returnBookingData
                        self.navigationController?.pushViewController(bookingAgreementController, animated: true)
                    }
                case .error?:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", bookingOperation.error!, "Understand")
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", "There was something error with system, please try again", "Understand")
                }
            }
        }
    }
}

extension BookingController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPlate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookingPlateCell", for: indexPath) as! BookingPlateCell
        cell.plateData = listPlate[indexPath.item]
        cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentMainClick(sender:))))
        return cell
    }
}

extension BookingController {
    @objc func iconCancelBookingClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func viewCarsClick() {
        vehicleType = 2
        changeToGreen(iconCars, "Artboard 130@0.75x-8", textCars)
        textSelectedVehicle.setTitle("Tap here", for: .normal)
        textSelectedVehicle.setTitleColor(UIColor.lightGray, for: .normal)
        textSelectedVehicle.layer.borderColor = UIColor.lightGray.cgColor
        pickedVehicle.text = ""
        pickVehicleType.accept(true)
        myVehicle.accept(false)
        
        if let building = buildingModel {
            if building.has_motor == 1 { changeToDefault(iconMotor, "Artboard 122@0.75x-8", textMotor) }
        }
    }
    
    @objc func viewMotorClick() {
        vehicleType = 1
        changeToGreen(iconMotor, "Artboard 131@0.75x-8", textMotor)
        textSelectedVehicle.setTitle("Tap here", for: .normal)
        textSelectedVehicle.setTitleColor(UIColor.lightGray, for: .normal)
        textSelectedVehicle.layer.borderColor = UIColor.lightGray.cgColor
        pickedVehicle.text = ""
        pickVehicleType.accept(true)
        myVehicle.accept(false)
        
        if let building = buildingModel {
            if building.has_mobil == 1 { changeToDefault(iconCars, "Artboard 15@0.75x-8", textCars) }
        }
    }
    
    @objc func viewValletClick() {
        parkingType = 1
        pickParkingType.accept(true)
        changeToGreen(iconVallet, "Artboard 132@0.75x-8", textVallet)
        
        if let building = buildingModel {
            if building.has_standard == 1 { changeToDefault(iconStandart, "Artboard 124@0.75x-8", textStandart) }
        }
    }
    
    @objc func viewStandartClick() {
        parkingType = 0
        pickParkingType.accept(true)
        changeToGreen(iconStandart, "Artboard 133@0.75x-8", textStandart)
        
        if let building = buildingModel {
            if building.has_valet == 1 { changeToDefault(iconVallet, "Artboard 123@0.75x-8", textVallet) }
        }
    }
    
    @objc func viewIndoorClick() {
        placeType = "in"
        pickParkingPlace.accept(true)
        changeToGreen(iconIndoor, "Artboard 134@0.75x-8", textIndoor)
        
        if let building = buildingModel {
            if building.has_outdoor == 1 { changeToDefault(iconOutdoor, "Artboard 126@0.75x-8", textOutdoor) }
        }
    }
    
    @objc func viewOutdoorClick() {
        placeType = "out"
        pickParkingPlace.accept(true)
        changeToGreen(iconOutdoor, "Artboard 135@0.75x-8", textOutdoor)
        
        if let building = buildingModel {
            if building.has_indoor == 1 { changeToDefault(iconIndoor, "Artboard 125@0.75x-8", textIndoor) }
        }
    }
    
    @objc func viewCreditDebitClick() {
        paymentType = 1
        pickParkingPayment.accept(true)
        changeToGreen(iconCreditDebit, "Artboard 136@0.75x-8", textCreditDebit)
        changeToDefault(iconCash, "Artboard 128@0.75x-8", textCash)
        changeToDefault(iconMycard, "Artboard 129@0.75x-8", textMycard)
    }
    
    @objc func viewPlateControllerClick() {
        let licensePlateController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LicensePlateController") as! LicensePlateController
        licensePlateController.licensePlateControllerProtocol = self
        navigationController?.pushViewController(licensePlateController, animated: true)
    }
    
    @objc func viewCashClick() {
        paymentType = 2
        pickParkingPayment.accept(true)
        changeToGreen(iconCash, "Artboard 137@0.75x-8", textCash)
        changeToDefault(iconCreditDebit, "Artboard 127@0.75x-8", textCreditDebit)
        changeToDefault(iconMycard, "Artboard 129@0.75x-8", textMycard)
    }
    
    @objc func viewMycardClick() {
        paymentType = 3
        pickParkingPayment.accept(true)
        changeToGreen(iconMycard, "Artboard 138@0.75x-8", textMycard)
        changeToDefault(iconCreditDebit, "Artboard 127@0.75x-8", textCreditDebit)
        changeToDefault(iconCash, "Artboard 128@0.75x-8", textCash)
    }
    
    @objc func buttonOrderClick() {
        switch formState {
        case .allow:
            if let building = self.buildingModel { self.booking(building) }
        default:
            PublicFunction.instance.showUnderstandDialog(self, "Empty Field", "Make sure to fill and choose every option before proceed to order your parking", "Understand")
        }
    }
    
    @objc func buttonAddPlateClick() {
        let licensePlateController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LicensePlateController") as! LicensePlateController
        licensePlateController.licensePlateControllerProtocol = self
        navigationController?.pushViewController(licensePlateController, animated: true)
    }
    
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textSelectedVehicleClick() {
        if let _ = vehicleType {
            viewContentPickVehicle.isHidden = false
            loadPlate()
        } else {
            PublicFunction.instance.showUnderstandDialog(self, "Empty Vehicle Type", "Please choose either car or motorcycle as your vehicle type", "Understand")
        }
    }
    
    @objc func viewCancelVehicleClick() {
        viewContentPickVehicle.isHidden = true
    }
    
    @objc func contentMainClick(sender: UITapGestureRecognizer) {
        if let indexPath = plateCollectionView.indexPathForItem(at: sender.location(in: plateCollectionView)) {
            pickedVehicle.text = self.listPlate[indexPath.item].number_plate
        }
    }
    
    @objc func viewPickVehicleClick() {
        viewContentPickVehicle.isHidden = true
        
        if pickedVehicle.text != "" {
            textSelectedVehicle.setTitle(pickedVehicle.text?.trim(), for: .normal)
            textSelectedVehicle.layer.borderColor = UIColor(rgb: 0x00A551).cgColor
            textSelectedVehicle.setTitleColor(UIColor(rgb: 0x00A551), for: .normal)
            self.myVehicle.accept(true)
        } else {
            PublicFunction.instance.showUnderstandDialog(self, "Pick Vehicle First", "You're not pick any vehicle yet", "Understand")
        }
    }
}

extension BookingController: LicensePlateControllerProtocol {
    func refreshData(listPlate: [PlateModel]) {
        self.pickedVehicle.text = ""
        
        self.listPlate.removeAll()
        
        for (index, plate) in listPlate.enumerated() {
            if plate.vehicle_id == self.vehicleType {
                self.listPlate.append(plate)
            }
            
            if index == listPlate.count - 1 {
                DispatchQueue.main.async {
                    self.plateCollectionView.isHidden = false
                    self.plateCollectionView.reloadData()
                    
                    if self.listPlate.count > 0 {
                        self.buttonAddPlate.isHidden = true
                    } else {
                        self.buttonAddPlate.isHidden = false
                    }
                }
            }
        }
    }
}
