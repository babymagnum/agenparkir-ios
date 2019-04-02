//
//  TabOngoingController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 21/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TabOngoingController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var iconBack: UIImageView!
    
    var vehicleType: Int?
    var fromBooking: Bool?
    var pages = [UIViewController]()
    var popRecognizer: InteractivePopRecognizer?
    var tab: String?
    
    override func viewDidLoad() {
        if let _ = fromBooking {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            setInteractiveRecognizer()
        }
        
        setupTabLayout()
        
        super.viewDidLoad()
        
        customView()
        
        handleGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tab = tab {
            switch tab{
            case "ParkingController":
                self.moveTo(viewController: pages[1], animated: true)
            default: break
            }
        }
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func handleGesture() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
    }
    
    private func customView() {
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x2B3990, alpha: 1.0)
    }
    
    func setupTabLayout() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.init(rgb: 0x2B3990)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = UIColor.init(rgb: 0x2B3990)
        }
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let parkingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParkingController") as! ParkingController
        parkingController.vehicleType = vehicleType
        let ticketingController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TicketingController") as! TicketingController
        
        pages.append(ticketingController)
        pages.append(parkingController)
        return pages
    }
}

extension TabOngoingController {
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
