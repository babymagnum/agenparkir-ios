//
//  OngoingController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 12/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol UpdateOngoingProtocol {
    func updateData()
}

class OngoingController: BaseViewController, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var emptyOngoing: UILabel!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewBarcode: UIView!
    @IBOutlet weak var viewMaps: UIView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var parkingStatus: UILabel!
    @IBOutlet weak var iconStatus: UIImageView!
    @IBOutlet weak var iconStatusHeight: NSLayoutConstraint!
    @IBOutlet weak var iconStatusWidth: NSLayoutConstraint!
    
    //MARK: Mutable Props
    var listOngoing = [OngoingModel]()
    var fromBooking: Bool?
    var vehicleType: Int?
    var timeLeftMotor = 600 //seconds
    var timeLeftCars = 900 //seconds
    var timerLast = 0
    var mTimer: Timer?
    var ongoingModel: OngoingModel?
    var allowStopTimer = true
    var popRecognizer: InteractivePopRecognizer?
    
    //MARK: Imutable Props
    let operation = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        //initCollectionView()

        customView()
        
        loadOngoing()
        
        handleGesture()
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if allowStopTimer {
            UserDefaults.standard.set(PublicFunction().getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), forKey: StaticVar.time_timer_removed)
            
            print("cancel timer because of user tap back in \(UserDefaults.standard.string(forKey: StaticVar.time_timer_removed) ?? "")")
            
            mTimer?.invalidate()
        }
        
        print("allow stop timer")
        
        self.allowStopTimer = true
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        viewMaps.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMapsClick)))
        viewInfo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewInfoClick)))
        viewBarcode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewBarcodeClick)))
        viewMessage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMessageClick)))
        
        if let _ = fromBooking {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(iconBackClick))
            swipeGesture.direction = .right
            self.view.addGestureRecognizer(swipeGesture)
        }
    }
    
    private func startTimer(_ data: OngoingModel){
        switch data.vehicle_type {
        case 1: //motor
            mTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                self.timeLeftMotor -= 1
                
                UserDefaults.standard.set(self.timeLeftMotor, forKey: StaticVar.last_timer)
                
                print("Sisa waktu \(self.timeLeftMotor)")
                
                self.timer.text = "\(self.timeLeftMotor / 60):\(self.timeLeftMotor % 60)"
                
                if self.timeLeftMotor == 0 {
                    timer.invalidate()
                }
            }
        case 2: //mobil
            mTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                self.timeLeftCars -= 1
                
                UserDefaults.standard.set(self.timeLeftCars, forKey: StaticVar.last_timer)
                
                print("Sisa waktu \(self.timeLeftCars)")
                
                self.timer.text = "\(self.timeLeftCars / 60):\(self.timeLeftCars % 60 > 10 ? self.timeLeftCars % 60 : Int("0\(self.timeLeftCars % 60)") ?? 1)"
                
                if self.timeLeftCars == 0 {
                    timer.invalidate()
                }
            }
        default:
            if self.timerLast > 0 {
                mTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    self.timerLast -= 1
                    
                    UserDefaults.standard.set(self.timerLast, forKey: StaticVar.last_timer)
                    
                    print("Sisa waktu \(self.timerLast)")
                    
                    self.timer.text = "\(self.timerLast / 60):\(self.timerLast % 60 > 10 ? self.timerLast % 60 : Int("0\(self.timerLast % 60)") ?? 1)"
                    
                    if self.timerLast == 0{
                        timer.invalidate()
                    }
                }
            } else {
                self.timer.text = "00:00"
            }
        }
    }
    
    private func loadOngoing() {
        SVProgressHUD.show()
        
        let listOngoingOperation = ListOngoingOperation(vehicle_type: vehicleType ?? 0)
        operation.addOperation(listOngoingOperation)
        listOngoingOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            switch listOngoingOperation.state {
            case .success?:
                //self.listOngoing = listOngoingOperation.listOngoing
                DispatchQueue.main.async {
                    self.ongoingModel = listOngoingOperation.listOngoing[0]
                    self.updateUI(listOngoingOperation.listOngoing[0])
                    self.contentMain.isHidden = false 
                }
            case .error?:
                PublicFunction().showUnderstandDialog(self, "Empty Order", listOngoingOperation.error!, "Understand")
                DispatchQueue.main.async {
                    self.emptyOngoing.text = listOngoingOperation.error!
                    self.emptyOngoing.isHidden = false
                    self.contentMain.isHidden = true
                }
            default:
                PublicFunction().showUnderstandDialog(self, "Error", "There was something error with system, please try refresh the page", "Understand")
                self.emptyOngoing.text = "There was something error with system, please try refresh the page"
                self.emptyOngoing.isHidden = false
            }
        }
    }
    
    private func updateUI(_ ongoingModel: OngoingModel) {
        venueName.text = ongoingModel.building_name
        
        if let date = ongoingModel.booking_start_time {
            let longDate = PublicFunction().dateStringToInt(stringDate: date, pattern: "yyyy-MM-dd kk:mm:ss")
            orderDate.text = PublicFunction().dateLongToString(dateInMillis: longDate, pattern: "dd MMMM yyyy, kk:mm a")
        } else {
            orderDate.text = PublicFunction().getCurrentDate(pattern: "dd MMMM yyyy kk:mm a")
        }
        
        if ongoingModel.vehicle_type == 0 {
            let difference = Calendar.current.dateComponents([.second], from: PublicFunction().getDate(stringDate: UserDefaults.standard.string(forKey: StaticVar.time_timer_removed)!, pattern: "yyyy-MM-dd kk:mm:ss")!, to: PublicFunction().getDate(stringDate: PublicFunction().getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), pattern: "yyyy-MM-dd kk:mm:ss")!).second!
            print("time left for canceled timer \(UserDefaults.standard.integer(forKey: StaticVar.last_timer))")
            print("difference between last time and current time \(difference)")
            self.timerLast = UserDefaults.standard.integer(forKey: StaticVar.last_timer) - difference
        }
        
        switch ongoingModel.booking_status_id {
        case 0:
            self.changeToCompletePayment("Parking lot reserved for you")
        case 1:
            parkingStatus.text = "Payment has not been setled"
            self.startTimer(ongoingModel)
        case 2:
            self.changeToCompletePayment("Payment Completed")
        case 3:
            self.changeToCompletePayment("Parking completed")
        default:
            parkingStatus.text = "Parking canceled"
        }
    }
    
    private func changeToCompletePayment(_ status: String) {
        mTimer?.invalidate()
        parkingStatus.text = status
        parkingStatus.textColor = UIColor.lightGray
        timer.text = ""
        iconStatus.image = UIImage(named: "Artboard 170@0.75x-8")
        iconStatusHeight.constant = 40
        iconStatusWidth.constant = 40
        self.view.layoutIfNeeded()
    }
    
    private func customView() {        
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x0D47A1, alpha: 1.0)
        contentMain.layer.cornerRadius = 10
        contentMain.clipsToBounds = false
        contentMain.layer.shadowColor = UIColor.lightGray.cgColor
        contentMain.layer.shadowOffset = CGSize(width: 1.5, height: 3)
        contentMain.layer.shadowRadius = 3
        contentMain.layer.shadowOpacity = 0.6
    }
}

extension OngoingController {
    @objc func viewMapsClick() {
        allowStopTimer = false
        if let model = ongoingModel {
            let directionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DirectionController") as! DirectionController
            
            switch vehicleType{
            case 1: //motor
                directionController.dataDirection = (latitude: model.latitude, longitude: model.longitude, building_name: model.building_name, timer: timeLeftMotor, booking_status_id: model.booking_status_id) as? (latitude: String, longitude: String, building_name: String, timer: Int, booking_status_id: Int)
            case 2: //mobil
                directionController.dataDirection = (latitude: model.latitude, longitude: model.longitude, building_name: model.building_name, timer: timeLeftCars, booking_status_id: model.booking_status_id) as? (latitude: String, longitude: String, building_name: String, timer: Int, booking_status_id: Int)
            default:
                directionController.dataDirection = (latitude: model.latitude, longitude: model.longitude, building_name: model.building_name, timer: timerLast, booking_status_id: model.booking_status_id) as? (latitude: String, longitude: String, building_name: String, timer: Int, booking_status_id: Int)
            }
            
            self.navigationController?.pushViewController(directionController, animated: true)
        }
    }
    
    @objc func viewBarcodeClick() {
        allowStopTimer = false
        if let model = ongoingModel {
            let qrCodeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QrCodeController") as! QrCodeController
            qrCodeController.bookingData = ((booking_code: model.booking_code, customer_name: model.name_customers, plate_number: model.plate_number) as! (booking_code: String, customer_name: String, plate_number: String))
            qrCodeController.delegate = self
            present(qrCodeController, animated: true)
        }
    }
    
    @objc func viewInfoClick() {
        allowStopTimer = false
        if let model = ongoingModel {
            let ongoingInfoController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OngoingInfoController") as! OngoingInfoController
            ongoingInfoController.ongoingModel = model
            self.present(ongoingInfoController, animated: true)
        }
    }
    
    @objc func viewMessageClick() {
        
    }
    
    @objc func willActive(_ notification: Notification) {
        if let model = ongoingModel {
            print("start timer again from background")
            
            if model.vehicle_type == 0 {
                let difference = Calendar.current.dateComponents([.second], from: PublicFunction().getDate(stringDate: UserDefaults.standard.string(forKey: StaticVar.time_timer_removed)!, pattern: "yyyy-MM-dd kk:mm:ss")!, to: PublicFunction().getDate(stringDate: PublicFunction().getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), pattern: "yyyy-MM-dd kk:mm:ss")!).second!
                print("time left for canceled timer \(UserDefaults.standard.integer(forKey: StaticVar.last_timer))")
                print("difference between last time and current time \(difference)")
                self.timerLast = UserDefaults.standard.integer(forKey: StaticVar.last_timer) - difference
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.startTimer(model)
            }
            return
        }
        
        loadOngoing()
    }
    
    @objc func willResignActive(_ notification: Notification) {
        UserDefaults.standard.set(PublicFunction().getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), forKey: StaticVar.time_timer_removed)
        
        print("cancel timer because of in background in \(UserDefaults.standard.string(forKey: StaticVar.time_timer_removed) ?? "")")
        
        mTimer?.invalidate()
    }
    
    @objc func iconBackClick() {
        if let _ = fromBooking {
            for (index, item) in (self.navigationController?.viewControllers.enumerated())! {
                var homeControllerId = "\(item)".components(separatedBy: ":")
                let clearHomeControllerId = homeControllerId[0].replacingOccurrences(of: "<", with: "")
    
                var hcID = "\(HomeController())".components(separatedBy: ":")
                let clearHcId = hcID[0].replacingOccurrences(of: "<", with: "")
                
                if clearHomeControllerId == clearHcId {
                    self.navigationController?.popToViewController(self.navigationController?.viewControllers[index] as! HomeController, animated: true)
                    break
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension OngoingController: UpdateOngoingProtocol {
    func updateData() {
        loadOngoing()
    }
}
