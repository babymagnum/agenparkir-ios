//
//  HomeController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 26/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation

class HomeController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var currentName: UILabel!
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var updatesCollectionView: UICollectionView!
    @IBOutlet weak var updatesCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var servicesCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var billboardCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var billboardCollectionView: UICollectionView!
    @IBOutlet weak var recentlyCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var viewNotification: UIImageView!
    @IBOutlet weak var viewSettings: UIImageView!
    @IBOutlet weak var viewAccount: UIView!
    @IBOutlet weak var viewCoin: UIView!
    @IBOutlet weak var imageAccount: UIImageView!
    @IBOutlet weak var viewCoinWidth: NSLayoutConstraint!
    @IBOutlet weak var amountCoin: UILabel!
    @IBOutlet weak var recentlyCollectionView: UICollectionView!
    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    @IBOutlet weak var imageUpdates: UIImageView!
    @IBOutlet weak var currentMyCard: UILabel!
    @IBOutlet weak var viewBooking: UIView!
    @IBOutlet weak var viewOngoing: UIView!
    @IBOutlet weak var viewReceipt: UIView!
    @IBOutlet weak var viewMycard: UIView!
    @IBOutlet weak var iconBookingBottom: UIImageView!
    @IBOutlet weak var iconOngoingBottom: UIImageView!
    @IBOutlet weak var iconReceiptBottom: UIImageView!
    @IBOutlet weak var iconMycardBottom: UIImageView!
    @IBOutlet weak var iconTopUp: UIImageView!
    
    //MARK: Props
    var listRecently = [RecentlyModel]()
    var listBillboard = [BillboardModel]()
    var listServices = [ServicesModel]()
    var listUpdates = [BuildingModel]()
    var billboardViewLayout: CarouselFlowLayout!
    var recentlyViewLayout: CarouselFlowLayout!
    var locationManager = CLLocationManager()
    let operationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("id homecontroller \(UserDefaults.standard.string(forKey: StaticVar.id) ?? "")")
        print("token homecontroller \(UserDefaults.standard.string(forKey: StaticVar.token) ?? "")")
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        customView()
        
        initCollectionView()
        
        initLocationManager()

        populateData()
        
        handleGestureListener()
    }
    
    private func populateData(){
        let recentlyOperation = RecentlyOperation()
        let billboardOperation = BillboardOperation()
        let servicesOperation = ServicesOperation()
        let currentOperation = CurrentOperation()
        
        operationQueue.addOperations([recentlyOperation, billboardOperation, servicesOperation, currentOperation], waitUntilFinished: false)
        
        currentOperation.completionBlock = {
            if let err = currentOperation.error {
                PublicFunction().showUnderstandDialog(self, "Error", err, "Understand")
            }
            
            guard let currentModel = currentOperation.currentModel else { return }
            
            self.updateCurrentData(currentModel)
        }
        
        recentlyOperation.completionBlock = {
            DispatchQueue.main.async {
                switch recentlyOperation.state {
                case .success?:
                    self.listRecently = recentlyOperation.listRecently
                    
                    self.recentlyCollectionView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.recentlyCollectionHeight.constant = self.recentlyCollectionView.contentSize.height
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                case .error?:
                    print("recently operation error \(recentlyOperation.error ?? "")")
                case .empty?:
                    self.contentMainHeight.constant -= self.recentlyCollectionHeight.constant
                    self.recentlyCollectionHeight.constant = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                default:
                    print("recently operation error by system")
                }
            }
        }
        
        billboardOperation.completionBlock = {
            DispatchQueue.main.async {
                switch billboardOperation.state {
                case .success?:
                    self.listBillboard = billboardOperation.listBillboard
                    
                    self.billboardCollectionView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.billboardCollectionHeight.constant = self.billboardCollectionView.contentSize.height
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                case .error?:
                    print("billboard operation error \(billboardOperation.error ?? "")")
                case .empty?:
                    self.contentMainHeight.constant -= self.billboardCollectionHeight.constant
                    self.billboardCollectionHeight.constant = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                default:
                    print("billboard operation error by system")
                }
            }
        }
        
        servicesOperation.completionBlock = {
            DispatchQueue.main.async {
                switch servicesOperation.state {
                case .success?:
                    self.listServices = servicesOperation.listServices
                    
                    self.contentMainHeight.constant -= self.servicesCollectionHeight.constant
                    self.servicesCollectionView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.servicesCollectionHeight.constant = self.servicesCollectionView.contentSize.height
                        self.contentMainHeight.constant += self.servicesCollectionView.contentSize.height
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                case .error?:
                    print("services operation error \(servicesOperation.error ?? "")")
                case .empty?:
                    UIView.animate(withDuration: 0.2, animations: {
                        self.contentMainHeight.constant -= self.servicesCollectionHeight.constant
                        self.servicesCollectionHeight.constant = 0
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                default:
                    print("services operation error by system")
                }
            }
        }
    }
    
    private func handleGestureListener() {
        iconTopUp.isUserInteractionEnabled = true
        iconTopUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconTopUpClick)))
        viewSettings.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSettingsClick)))
        viewBooking.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewBookingClick)))
        viewOngoing.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewOngoingClick)))
        viewReceipt.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewReceiptClick)))
        iconBookingBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewBookingClick)))
        iconOngoingBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewOngoingClick)))
        iconReceiptBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewReceiptClick)))
        viewMycard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMycardClick)))
        iconMycardBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMycardClick)))
    }
    
    private func initLocationManager() {
        //this line of code below to prompt the user for location permission
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
        locationManager.startUpdatingLocation()
    }
    
    private func updateCurrentData(_ currentModel: CurrentModel) {
        DispatchQueue.main.async {
            self.currentName.text = currentModel.name
            self.currentMyCard.text = currentModel.getMyCard()
            
            if currentModel.images == "" {
                self.imageAccount.image = UIImage(named: "Artboard 123@0.75x-8")
            } else {
                let url = "\(StaticVar.root_images)\(currentModel.images ?? "")"
                self.imageAccount.loadUrl(url)
            }
        }
    }
    
    private func initCollectionView() {
        //recently collectionview
        let screenSize = UIScreen.main.bounds
        
        recentlyViewLayout = CarouselFlowLayout.configureLayout(collectionView: recentlyCollectionView, itemSize: CGSize(width: floor(screenSize.width * 0.5), height: 159), minimumLineSpacing: 0)
        recentlyViewLayout.minimumScaleFactor = 0.8
        
        recentlyCollectionView.showsHorizontalScrollIndicator = false
        recentlyCollectionView.delegate = self
        recentlyCollectionView.dataSource = self
        
        //billboard collectionview
        billboardViewLayout = CarouselFlowLayout.configureLayout(collectionView: self.billboardCollectionView, itemSize: CGSize(width: floor(screenSize.width * 0.5), height: 147), minimumLineSpacing: 0)
        billboardViewLayout.minimumScaleFactor = 0.8
        
        billboardCollectionView.delegate = self
        billboardCollectionView.dataSource = self
        billboardCollectionView.showsHorizontalScrollIndicator = false
        
        //service collectionview
        servicesCollectionView.delegate = self
        servicesCollectionView.dataSource = self
        servicesCollectionView.showsVerticalScrollIndicator = false
        
        //updates collectionview
        updatesCollectionView.delegate = self
        updatesCollectionView.dataSource = self
        updatesCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func customView() {
        imageUpdates.clipsToBounds = true
        imageUpdates.layer.cornerRadius = 10
        imageUpdates.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewNotification.layer.cornerRadius = viewNotification.frame.width / 2
        viewSettings.layer.cornerRadius = viewSettings.frame.width / 2
        viewAccount.layer.cornerRadius = 10
        imageAccount.clipsToBounds = true
        imageAccount.layer.cornerRadius = imageAccount.frame.width / 2
        viewCoin.layer.cornerRadius = 20
    }
}

//MARK: Location manager stuff
extension HomeController {
    //below code is triggered whenever the system is getting the current location after updating the location in viewdidload
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            UserDefaults.standard.set("\(latitude)", forKey: StaticVar.latitude)
            UserDefaults.standard.set("\(longitude)", forKey: StaticVar.longitude)
            
            let showBuildingOperation = ShowListBuildingOperation((pageNumber: 1, purpose: .home, nameQuery: ""))
            operationQueue.addOperation(showBuildingOperation)
            
            showBuildingOperation.completionBlock = {
                DispatchQueue.main.async {
                    switch showBuildingOperation.state {
                    case .success?:
                        self.listUpdates = showBuildingOperation.listBuilding
                        
                        self.contentMainHeight.constant -= self.updatesCollectionHeight.constant
                        self.updatesCollectionView.reloadData()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.updatesCollectionHeight.constant = self.updatesCollectionView.contentSize.height
                            self.contentMainHeight.constant += self.updatesCollectionHeight.constant
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.contentMain.layoutIfNeeded()
                        })
                    case .error?:
                        print("show list building error \(showBuildingOperation.error ?? "")")
                    case .empty?:
                        self.contentMainHeight.constant -= self.updatesCollectionHeight.constant
                        self.updatesCollectionHeight.constant = 0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.contentMain.layoutIfNeeded()
                        })
                    default:
                        print("show list building operation error by system")
                    }
                }
            }
        }
    }

    //below code will triggered when system failed get lat and long
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        UserDefaults.standard.set(0, forKey: StaticVar.latitude)
        UserDefaults.standard.set(0, forKey: StaticVar.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                    message: "In order to deliver pizza we need your location",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(openAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension HomeController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == servicesCollectionView {
            let service = listServices[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServicesCell", for: indexPath) as! ServicesCell
            
            let approximateTextWidth = cell.viewContentText.frame.width - 10 - 10
            let size = CGSize(width: approximateTextWidth, height: 100)
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
            let estimatedFrame = NSString(string: service.description!).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            return CGSize(width: UIScreen.main.bounds.width - 40, height: estimatedFrame.height + cell.servicesName.frame.height + 60 + cell.servicesDate.frame.height + cell.iconStar.frame.height)
        } else if collectionView == billboardCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BillboardCell", for: indexPath) as! BillboardCell
            return CGSize(width: floor(UIScreen.main.bounds.width * 0.5), height: cell.image.frame.height)
        } else if collectionView == updatesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpdatesCell", for: indexPath) as! UpdatesCell
            return CGSize(width: UIScreen.main.bounds.width - 60, height: cell.contentMain.frame.height)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyParkCell", for: indexPath) as! RecentlyParkCell
            return CGSize(width: floor(UIScreen.main.bounds.width * 0.5), height: cell.image.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recentlyCollectionView {
            return listRecently.count
        } else if collectionView == servicesCollectionView {
            return listServices.count
        } else if collectionView == updatesCollectionView {
            return listUpdates.count
        } else {
            return listBillboard.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == recentlyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentlyParkCell", for: indexPath) as! RecentlyParkCell
            cell.recentlyData = listRecently[indexPath.row]
            cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recentlyContentClick(sender:))))
            return cell
        } else if collectionView == servicesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServicesCell", for: indexPath) as! ServicesCell
            cell.servicesData = listServices[indexPath.row]
            return cell
        } else if collectionView == updatesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpdatesCell", for: indexPath) as! UpdatesCell
            cell.updatesData = listUpdates[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BillboardCell", for: indexPath) as! BillboardCell
            cell.billboardData = listBillboard[indexPath.row]
            cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(billboardContentMainClick(sender:))))
            return cell
        }
    }
}

extension HomeController: UpdateCurrentDataProtocol {
    func updateData() {
        SVProgressHUD.show()
        
        let currentOperation = CurrentOperation()
        operationQueue.addOperation(currentOperation)
        
        currentOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            if let err = currentOperation.error {
                PublicFunction().showUnderstandDialog(self, "Error", err, "Understand")
            }
            
            guard let currentModel = currentOperation.currentModel else { return }
            
            self.updateCurrentData(currentModel)
        }
    }
}

//MARK: Handle Gesture Listener
extension HomeController {
    @objc func iconTopUpClick() {
        let topUpController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopupController") as! TopupController
        topUpController.delegate = self
        navigationController?.pushViewController(topUpController, animated: true)
    }
    
    @objc func recentlyContentClick(sender: UITapGestureRecognizer){
        if let indexpath = recentlyCollectionView.indexPathForItem(at: sender.location(in: recentlyCollectionView)){
            let bookingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookingController") as! BookingController
            bookingController.building_id = listRecently[indexpath.row].building_id
            navigationController?.pushViewController(bookingController, animated: true)
        }
    }
    
    @objc func viewReceiptClick() {
        let receiptsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiptsController") as! ReceiptsController
        navigationController?.pushViewController(receiptsController, animated: true)
    }
    
    @objc func viewOngoingClick() {
        let tabOngoingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabOngoingController") as! TabOngoingController
        navigationController?.pushViewController(tabOngoingController, animated: true)
    }
    
    @objc func viewBookingClick() {
        let buildingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuildingController") as! BuildingController
        navigationController?.pushViewController(buildingController, animated: true)
    }
    
    @objc func viewSettingsClick() {
        let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
        settingsController.delegate = self
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @objc func billboardContentMainClick(sender: UITapGestureRecognizer) {
        if let indexpath = billboardCollectionView.indexPathForItem(at: sender.location(in: billboardCollectionView)) {
            print("billboard id \(listBillboard[indexpath.row].id ?? 0)")
        }
    }
    
    @objc func viewMycardClick() {
        let mycardController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCardController") as! MyCardController
        navigationController?.pushViewController(mycardController, animated: true)
    }
}
