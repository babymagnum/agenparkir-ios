//
//  LicensePlateController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 07/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

enum AllowCreate {
    case allow, dont
}

protocol LicensePlateControllerProtocol {
    func refreshData(listPlate: [PlateModel])
}

class LicensePlateController: BaseViewController, UITextFieldDelegate, UICollectionViewDelegate, BaseViewControllerProtocol {
    
    //MARK: Outlet
    @IBOutlet weak var iconEditPlateNumber: UIImageView!
    @IBOutlet weak var emptyPlateLabel: UILabel!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var iconEdit: UIImageView!    
    @IBOutlet weak var inputPlateNumber: UITextField!
    @IBOutlet weak var inputVehicleName: UITextField!
    @IBOutlet weak var viewCreate: UIView!
    @IBOutlet weak var iconCreate: UIImageView!
    @IBOutlet weak var plateCollectionView: UICollectionView!
    @IBOutlet weak var linePlateNumber: UIView!
    @IBOutlet weak var lineVehicleName: UIView!
    @IBOutlet weak var viewCars: UIView!
    @IBOutlet weak var viewMotorCycle: UIView!
    @IBOutlet weak var textCars: UILabel!
    @IBOutlet weak var textMotorcycle: UILabel!
    @IBOutlet weak var iconCars: UIImageView!
    @IBOutlet weak var iconMotorcycle: UIImageView!
    
    //MARK: Props
    var listPlate = [PlateModel]()
    let operationQueue = OperationQueue()
    var vehicleType = BehaviorRelay(value: "")
    var popRecognizer: InteractivePopRecognizer?
    let bag = DisposeBag()
    var enableCreate = AllowCreate.dont
    var understand = false
    var licensePlateControllerProtocol: LicensePlateControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setInteractiveRecognizer()
        
        customView()
        
        initTextFieldDelegate()
        
        initCollectionView()
        
        loadListPlate()
        
        handleGesture()
        
        bindUI()
    }
    
    private func initTextFieldDelegate() {
        inputPlateNumber.tag = 1
        inputVehicleName.tag = 2
        inputPlateNumber.delegate = self
        inputVehicleName.delegate = self        
    }
    
    private func bindUI() {
        
        Observable.combineLatest(inputPlateNumber.rx.text, inputVehicleName.rx.text, vehicleType.asObservable(), resultSelector: { plate, name, vehicleType in
            if (plate?.trim().count)! == 10 {
                self.inputPlateNumber.isEnabled = false
                let alert = UIAlertController(title: "Reach Max", message: "Plate number should contains maximal of 10 character", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Edit", style: .cancel, handler: { (UIAlertAction) in
                    self.inputPlateNumber.text = ""
                    self.iconEditPlateNumber.isHidden = true
                    self.inputPlateNumber.isEnabled = true
                    self.understand = false
                    self.linePlateNumber.backgroundColor = UIColor(rgb: 0xd50000)
                }))
                alert.addAction(UIAlertAction(title: "Use this", style: .default, handler: { (action) in
                    self.iconEditPlateNumber.isHidden = false
                    self.understand = true
                }))
                
                if !self.understand {
                    self.present(alert, animated: true)
                }
            } else if (plate?.trim().count)! > 0 {
                self.inputPlateNumber.textColor = UIColor(rgb: 0x00A551)
                self.linePlateNumber.backgroundColor = UIColor(rgb: 0x00A551)
                self.inputPlateNumber.isEnabled = true
            } else {
                self.linePlateNumber.backgroundColor = UIColor(rgb: 0xd50000)
                self.inputPlateNumber.isEnabled = true
            }
            
            if (name?.trim().count)! > 0 {
                self.inputVehicleName.textColor = UIColor(rgb: 0x00A551)
                self.lineVehicleName.backgroundColor = UIColor(rgb: 0x00A551)
            } else {
                self.lineVehicleName.backgroundColor = UIColor(rgb: 0xd50000)
            }
            
            if (name?.trim().count)! > 0 && (plate?.trim().count)! > 0 && vehicleType != "" {
                self.viewCreate.backgroundColor = UIColor(rgb: 0x00A551)
                self.enableCreate = .allow
            } else {
                self.viewCreate.backgroundColor = UIColor(rgb: 0xd50000)
                self.enableCreate = .dont
            }
        }).subscribe().disposed(by: bag)
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    private func handleGesture() {
        viewCreate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCreateClick)))
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackCLick)))
        viewCars.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCarsClick)))
        viewMotorCycle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMotorCycleClick)))
        iconEditPlateNumber.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconEditPlateNumberClick)))
        emptyPlateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyPlateLabelClick)))
    }
    
    private func loadListPlate() {
        let showPlateOperation = ShowListPlateOperation()
        operationQueue.addOperation(showPlateOperation)
        
        showPlateOperation.completionBlock = {
            switch showPlateOperation.state {
            case .success?:
                self.listPlate = showPlateOperation.listPlate
                DispatchQueue.main.async {
                    self.emptyPlateLabel.isHidden = true
                    self.plateCollectionView.isHidden = false
                    self.plateCollectionView.reloadData()
                    
                    if let licenseProtocol = self.licensePlateControllerProtocol {
                        licenseProtocol.refreshData(listPlate: showPlateOperation.listPlate)
                    }
                }
            case .error?:
                PublicFunction.instance.showUnderstandDialog(self, "Error Get List Plate", showPlateOperation.error!, "Understand")
            case .empty?:
                DispatchQueue.main.async {
                    self.emptyPlateLabel.isHidden = false
                    self.plateCollectionView.isHidden = true
                }
            default:
                PublicFunction.instance.showUnderstandDialog(self, "Error!", "Please click the retry button to refresh data", "Understand")
            }
        }
    }
    
    func hasInternet() {
        emptyPlateLabel.text = "You haven't registered any vehicle yet."
    }
    
    func noInternet() {
        emptyPlateLabel.attributedText = reloadString()
        
        if listPlate.count == 0 {
            emptyPlateLabel.isHidden = false
        }
    }
    
    private func initCollectionView() {
        plateCollectionView.delegate = self
        plateCollectionView.dataSource = self
        plateCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func customView() {
        baseDelegate = self
        viewCreate.clipsToBounds = true
        viewCreate.layer.cornerRadius = viewCreate.frame.height / 2
        PublicFunction.instance.changeTintColor(imageView: iconCreate, hexCode: 0xffffff, alpha: 1)
        PublicFunction.instance.changeTintColor(imageView: iconBack, hexCode: 0x000000, alpha: 0.8)
        PublicFunction.instance.changeTintColor(imageView: iconEdit, hexCode: 0x000000, alpha: 0.8)
    }
    
    private func changeToGreen(_ view: UIView, _ text: UILabel) {
        view.backgroundColor = UIColor(rgb: 0x00A551)
        text.textColor = UIColor(rgb: 0x00A551)
    }
    
    private func changeToRed(_ view: UIView, _ text: UILabel) {
        view.backgroundColor = UIColor(rgb: 0xd50000)
        text.textColor = UIColor(rgb: 0xd50000)
    }
    
    private func setToDefault() {
        DispatchQueue.main.async {
            self.vehicleType.accept("")
            self.inputPlateNumber.text = ""
            self.linePlateNumber.backgroundColor = UIColor(rgb: 0xd50000)
            self.inputVehicleName.text = ""
            self.lineVehicleName.backgroundColor = UIColor(rgb: 0xd50000)
            self.viewCreate.backgroundColor = UIColor(rgb: 0xd50000)
            self.textCars.textColor = UIColor(rgb: 0xd50000)
            self.textMotorcycle.textColor = UIColor(rgb: 0xd50000)
            self.iconCars.image = UIImage(named: "Artboard 171@0.75x-8")
            self.iconMotorcycle.image = UIImage(named: "Artboard 172@0.75x-8")
            self.inputPlateNumber.isEnabled = true
            self.inputVehicleName.isEnabled = true
            self.iconEditPlateNumber.isHidden = true
        }
    }
    
    private func deletePlate(_ plateModel: PlateModel, _ positionInList: Int) {
        SVProgressHUD.show()
        let deletePlateOperation = DeletePlateOperation(String(plateModel.plate_id))
        operationQueue.addOperation(deletePlateOperation)
        deletePlateOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            switch deletePlateOperation.state {
            case .success?:
                PublicFunction.instance.showUnderstandDialog(self, "Success Delete", "Success delete plate with number \(plateModel.number_plate ?? "")", "Cancel")
                self.listPlate.remove(at: positionInList)
                
                if let licenseProtocol = self.licensePlateControllerProtocol {
                    licenseProtocol.refreshData(listPlate: self.listPlate)
                }
                
                DispatchQueue.main.async {
                    self.plateCollectionView.reloadData()
                    
                    if self.listPlate.count == 0 {
                        self.emptyPlateLabel.isHidden = false
                        self.plateCollectionView.isHidden = true
                    }
                }
            case .canceled?:
                PublicFunction.instance.showUnderstandDialog(self, "Error Delete", "Failed when deleting vehicle with plate \(plateModel.number_plate ?? ""), please try again", "Understand")
            default:
                PublicFunction.instance.showUnderstandDialog(self, "Error Delete", "Failed when deleting vehicle, error: \(deletePlateOperation.error ?? "")", "Understand")
            }
        }
    }
}

//MARK: Handle gesture
extension LicensePlateController {
    @objc func emptyPlateLabelClick() {
        loadListPlate()
    }
    
    @objc func iconEditPlateNumberClick() {
        inputPlateNumber.text = ""
        linePlateNumber.backgroundColor = UIColor(rgb: 0xd50000)
        iconEditPlateNumber.isHidden = true
        inputPlateNumber.isEnabled = true
        understand = false
    }
    
    @objc func viewMotorCycleClick() {
        vehicleType.accept("1")
        textMotorcycle.textColor = UIColor(rgb: 0x00A551)
        textCars.textColor = UIColor(rgb: 0xd50000)
        iconMotorcycle.image = UIImage(named: "Artboard 131@0.75x-8")
        iconCars.image = UIImage(named: "Artboard 171@0.75x-8")
    }
    
    @objc func viewCarsClick() {
        vehicleType.accept("2")
        textCars.textColor = UIColor(rgb: 0x00A551)
        textMotorcycle.textColor = UIColor(rgb: 0xd50000)
        iconCars.image = UIImage(named: "Artboard 130@0.75x-8")
        iconMotorcycle.image = UIImage(named: "Artboard 172@0.75x-8")
    }
    
    @objc func iconBackCLick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func iconDeleteClick(sender: UITapGestureRecognizer) {
        if let indexPath = plateCollectionView.indexPathForItem(at: sender.location(in: plateCollectionView)) {
            let alert = UIAlertController(title: "Delete Plate", message: "Do you want to delete \(listPlate[indexPath.item].number_plate ?? "") / \(listPlate[indexPath.item].title_plate ?? "")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
                self.deletePlate(self.listPlate[indexPath.item], indexPath.item)
            }))
            self.present(alert, animated: true)
        }
    }
    
    @objc func viewCreateClick() {
        inputPlateNumber.resignFirstResponder()
        inputVehicleName.resignFirstResponder()
        
        if enableCreate == .dont {
            PublicFunction.instance.showUnderstandDialog(self, "Form not Complete", "Make sure to choose the vehicle type then input the plate number and vehicle name before proceed", "Understand")
            return
        }
        
        SVProgressHUD.show()
        
        let postPlateOperation = PostPlateOperation(dataPlate: (vehicle_id: vehicleType.value, number_plate: (inputPlateNumber.text?.trim())!, title: (inputVehicleName.text?.trim())!))
        operationQueue.addOperation(postPlateOperation)
        
        postPlateOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            switch postPlateOperation.state {
            case .success?:
                PublicFunction.instance.showUnderstandDialog(self, "Success", "Success registered your vehicle", "Understand")
                self.setToDefault()
                self.loadListPlate()
            case .error?:
                PublicFunction.instance.showUnderstandDialog(self, "Error", postPlateOperation.error!, "Understand")
            default: //canceled
                PublicFunction.instance.showUnderstandDialog(self, "Error", "There was something error with system, please try again to registered your vehicle", "Understand")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 { //input plate
            inputVehicleName.becomeFirstResponder()
        } else if textField.tag == 2 {
            inputVehicleName.resignFirstResponder()
        }
        
        return true
    }
}

//MARK: Collectionview stuff
extension LicensePlateController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPlate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlateCell", for: indexPath) as! PlateCell
        cell.plateData = listPlate[indexPath.item]
        cell.iconDelete.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconDeleteClick(sender:))))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlateCell", for: indexPath) as! PlateCell
        let height = cell.contentMain.frame.height
        let width = UIScreen.main.bounds.width - 30
        return CGSize(width: width, height: height)
    }
}
