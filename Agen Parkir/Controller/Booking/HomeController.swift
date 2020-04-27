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
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin

class HomeController: BaseViewController, CLLocationManagerDelegate, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var viewPopupPayment: UIView!
    @IBOutlet weak var viewPopupPaymentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelPopupPayment: UILabel!
    @IBOutlet weak var iconPopupPayment: UIImageView!
    @IBOutlet weak var iconCoins: UIImageView!
    @IBOutlet weak var currentName: UILabel!
    @IBOutlet weak var homeScrollView: UIScrollView!
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
    var channelUrl: String?
    var listRecently = [RecentlyModel]()
    var listBillboard = [BillboardModel]()
    var listServices = [VoucherModel]()
    var listUpdates = [BuildingModel]()
    var billboardViewLayout: CarouselFlowLayout!
    var recentlyViewLayout: CarouselFlowLayout!
    var locationManager = CLLocationManager()
    let operationQueue = OperationQueue()
    
    var newsId: String?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = channelUrl {
            DispatchQueue.main.async {
                let chatController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatController") as! ChatController
                chatController.channelUrl = url
                self.navigationController?.pushViewController(chatController, animated: true)
            }
        }
    }
    
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
        
        if let _newsId = newsId {
            print("get data from appdelegate")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let vc = DetailNewsController()
                vc.newsId = _newsId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.recentlyCollectionView.collectionViewLayout.invalidateLayout()
            self.billboardCollectionView.collectionViewLayout.invalidateLayout()
            self.servicesCollectionView.collectionViewLayout.invalidateLayout()
            self.updatesCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func hideServiceCollection() {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentMainHeight.constant -= self.servicesCollectionHeight.constant
            self.servicesCollectionHeight.constant = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.contentMain.layoutIfNeeded()
        })
    }
    
    private func populateData(){
        SVProgressHUD.show()
        
        let recentlyOperation = RecentlyOperation()
        let billboardOperation = BillboardOperation()
        let paymentPendingOperation = PaymentPendingOperation()
        let currentOperation = CurrentOperation()
        
        operationQueue.addOperation(currentOperation)
        operationQueue.addOperation(recentlyOperation)
        operationQueue.addOperation(billboardOperation)
        operationQueue.addOperation(paymentPendingOperation)
        
        paymentPendingOperation.completionBlock = {
            DispatchQueue.main.async {
                switch paymentPendingOperation.state {
                case .success?:
                    self.viewPopupPayment.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        self.viewPopupPaymentHeightConstraint.constant = 50
                        self.labelPopupPayment.text = "You have \(paymentPendingOperation.listPaymentPending.count) payment pending. Check it here..."
                    })
                case .error?:
                    self.viewPopupPayment.isHidden = true
                    self.viewPopupPaymentHeightConstraint.constant = 0
                default: break
                }
            }
        }
        
        Networking.instance.getVoucherList { (list, error) in
            DispatchQueue.main.async {
                if let _ = error {
                    self.hideServiceCollection()
                    return
                }
                
                guard let list = list else {
                    self.hideServiceCollection()
                    return
                }
                
                if list.count == 0 {
                    self.hideServiceCollection()
                    return
                }
                
                for (index, value) in list.enumerated() {
                    var dataValue = value
                    
                    dataValue.description = "Hanya dengan menukar coin sebanyak \(value.coin_price ?? 0) coin, kamu bisa mendapatkan saldo My Card sebanyak \(value.value ?? 0)."
                    
                    self.listServices.append(dataValue)
                    
                    if index == 1 {
                        DispatchQueue.main.async {
                            self.contentMainHeight.constant -= self.servicesCollectionHeight.constant
                            self.servicesCollectionView.reloadData()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.servicesCollectionHeight.constant = self.servicesCollectionView.contentSize.height
                            self.contentMainHeight.constant += self.servicesCollectionView.contentSize.height
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                            self.contentMain.layoutIfNeeded()
                        })
                        break
                    }
                }
            }
        }
        
        currentOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch currentOperation.state {
                case .success?:
                    self.updateCurrentData(currentOperation.currentModel!)
                case .error?:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", currentOperation.error!, "Understand")
                case .expired?:
                    let alert = UIAlertController(title: "Session Expired", message: currentOperation.error!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
                        PublicFunction.instance.logout(self)
                    }))
                    self.present(alert, animated: true)
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", "There was some error with system, please try again", "Understand")
                }
            }
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                case .error?:
                    print("recently operation error \(recentlyOperation.error ?? "")")
                case .empty?:
                    self.contentMainHeight.constant -= self.recentlyCollectionHeight.constant
                    self.recentlyCollectionHeight.constant = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                case .error?:
                    print("billboard operation error \(billboardOperation.error ?? "")")
                case .empty?:
                    self.contentMainHeight.constant -= self.billboardCollectionHeight.constant
                    self.billboardCollectionHeight.constant = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        self.contentMain.layoutIfNeeded()
                    })
                default:
                    print("billboard operation error by system")
                }
            }
        }
        
        Networking.instance.getCoins(customer_id: UserDefaults.standard.string(forKey: StaticVar.id)!) { (coins, customer_id, error) in
            DispatchQueue.main.async {
                if let _ = error { return }
                
                let approximateTextWidth = self.amountCoin.frame.width - 10 - 10
                let size = CGSize(width: approximateTextWidth, height: 100)
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
                let estimatedFrame = NSString(string: "\(coins ?? 0)").boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewCoinWidth.constant = self.iconCoins.frame.width + estimatedFrame.width + 2.5 + 25
                    self.view.layoutIfNeeded()
                })
                
                self.amountCoin.text = "\(coins ?? 0)"
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
        viewNotification.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewNotificationClick)))
        iconMycardBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewMycardClick)))
        viewCoin.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewCoinClick)))
        viewPopupPayment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewPopupPaymentClick)))
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
        
        homeScrollView.addSubview(refreshControl)
        
        recentlyViewLayout = CarouselFlowLayout.configureLayout(collectionView: recentlyCollectionView, itemSize: CGSize(width: floor(screenSize.width * 0.5), height: 159), minimumLineSpacing: 0)
        recentlyViewLayout.minimumScaleFactor = 0.8
        
        recentlyCollectionView.isPrefetchingEnabled = false
        recentlyCollectionView.showsHorizontalScrollIndicator = false
        recentlyCollectionView.delegate = self
        recentlyCollectionView.dataSource = self
        
        //billboard collectionview
        billboardViewLayout = CarouselFlowLayout.configureLayout(collectionView: self.billboardCollectionView, itemSize: CGSize(width: floor(screenSize.width * 0.5), height: 147), minimumLineSpacing: 0)
        billboardViewLayout.minimumScaleFactor = 0.8
        
        billboardCollectionView.isPrefetchingEnabled = false
        billboardCollectionView.delegate = self
        billboardCollectionView.dataSource = self
        billboardCollectionView.showsHorizontalScrollIndicator = false
        
        //service collectionview
        servicesCollectionView.isPrefetchingEnabled = false
        servicesCollectionView.delegate = self
        servicesCollectionView.dataSource = self
        servicesCollectionView.showsVerticalScrollIndicator = false
        
        //updates collectionview
        updatesCollectionView.isPrefetchingEnabled = false
        updatesCollectionView.delegate = self
        updatesCollectionView.dataSource = self
        updatesCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func customView() {
        iconPopupPayment.image = UIImage(named: "Artboard 180@0.75x-8")?.tinted(with: UIColor(rgb: 0xffffff))
        viewPopupPayment.layer.cornerRadius = 5
        viewPopupPayment.clipsToBounds = false
        viewPopupPayment.layer.shadowColor = UIColor.lightGray.cgColor
        viewPopupPayment.layer.shadowOffset = CGSize(width: 2.5, height: 5)
        viewPopupPayment.layer.shadowRadius = 5
        viewPopupPayment.layer.shadowOpacity = 0.8
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
        
        self.loadTop5Parking(location)
    }
    
    private func loadTop5Parking(_ location: CLLocation) {
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
                        
                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                            self.contentMain.layoutIfNeeded()
                        })
                    case .error?:
                        print("show list building error \(showBuildingOperation.error ?? "")")
                    case .empty?:
                        self.contentMainHeight.constant -= self.updatesCollectionHeight.constant
                        self.updatesCollectionHeight.constant = 0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
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
            let estimatedFrame = NSString(string: service.description ?? "").boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
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
            cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(serviceContentMainClick)))
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
        let paymentPendingOperation = PaymentPendingOperation()
        operationQueue.addOperations([currentOperation, paymentPendingOperation], waitUntilFinished: false)
        
        paymentPendingOperation.completionBlock = {
            DispatchQueue.main.async {
                switch paymentPendingOperation.state {
                case .success?:
                    self.viewPopupPayment.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        self.viewPopupPaymentHeightConstraint.constant = 50
                        self.labelPopupPayment.text = "You have \(paymentPendingOperation.listPaymentPending.count) payment pending. Check it here..."
                    })
                case .error?:
                    self.viewPopupPayment.isHidden = true
                    self.viewPopupPaymentHeightConstraint.constant = 0
                default: break
                }
            }
        }
        
        currentOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if let err = currentOperation.error {
                    PublicFunction.instance.showUnderstandDialog(self, "Error", err, "Understand")
                }
                
                guard let currentModel = currentOperation.currentModel else { return }
                
                self.updateCurrentData(currentModel)
            }
        }
    }
}

//MARK: Handle Gesture Listener
extension HomeController {
    @objc func serviceContentMainClick() {
        let voucherController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoucherController") as! VoucherController
        navigationController?.pushViewController(voucherController, animated: true)
    }
    
    @objc func viewCoinClick() {
        let voucherController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoucherController") as! VoucherController
        navigationController?.pushViewController(voucherController, animated: true)
    }
    
    @objc func iconTopUpClick() {
        let topUpController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopupController") as! TopupController
        topUpController.delegate = self
        navigationController?.pushViewController(topUpController, animated: true)
    }
    
    @objc func recentlyContentClick(sender: UITapGestureRecognizer){
        if let indexpath = recentlyCollectionView.indexPathForItem(at: sender.location(in: recentlyCollectionView)){
            let bookingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookingController") as! BookingController
            bookingController.building_id = listRecently[indexpath.item].building_id
            navigationController?.pushViewController(bookingController, animated: true)
        }
    }
    
    @objc func viewReceiptClick() {
        let receiptsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiptsController") as! ReceiptsController
        navigationController?.pushViewController(receiptsController, animated: true)
    }
    
    @objc func viewOngoingClick() {
        let tabOngoingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabOngoingController") as! TabOngoingController
        tabOngoingController.updateDelegate = self
        navigationController?.pushViewController(tabOngoingController, animated: true)
    }
    
    @objc func viewBookingClick() {
        let buildingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuildingController") as! BuildingController
        navigationController?.pushViewController(buildingController, animated: true)
    }
    
    @objc func viewPopupPaymentClick() {
        let tabOngoingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabOngoingController") as! TabOngoingController
        tabOngoingController.updateDelegate = self
        tabOngoingController.tab = "PaymentPendingController"
        navigationController?.pushViewController(tabOngoingController, animated: true)
    }
    
    @objc func viewSettingsClick() {
        let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
        settingsController.delegate = self
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @objc func billboardContentMainClick(sender: UITapGestureRecognizer) {
        if let indexpath = billboardCollectionView.indexPathForItem(at: sender.location(in: billboardCollectionView)) {
            let detailStoreController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailStoreController") as! DetailStoreController
            var storeModel = StoreModel()
            storeModel.store_id = listBillboard[indexpath.item].store_id
            storeModel.address = listBillboard[indexpath.item].address
            storeModel.time = listBillboard[indexpath.item].time
            storeModel.images = listBillboard[indexpath.item].images
            storeModel.description = listBillboard[indexpath.item].description
            storeModel.name_store = listBillboard[indexpath.item].name_store
            detailStoreController.storeDetail = storeModel
            self.navigationController?.pushViewController(detailStoreController, animated: true)
        }
    }
    
    @objc func viewMycardClick() {
        let mycardController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCardController") as! MyCardController
        mycardController.delegate = self
        navigationController?.pushViewController(mycardController, animated: true)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        populateData()
        refreshControl.endRefreshing()
    }
    
    @objc func viewNotificationClick() {
        showDevelopmentFeature()
    }
}
