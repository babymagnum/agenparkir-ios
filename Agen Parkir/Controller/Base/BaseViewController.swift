//
//  BaseViewController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 10/04/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

protocol BaseViewControllerProtocol {
    func noInternet()
    func hasInternet()
}

class BaseViewController: UIViewController {

    var baseDelegate: BaseViewControllerProtocol?
    
//    var timer: Timer?
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
//            if NetworkManager.shared.isConnected() {
//                print("connected")
//            } else {
//                print("not connected")
//            }
//        })
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        timer?.invalidate()
//    }
    
    func reloadString() -> NSMutableAttributedString {
        let mainString = "No internet connection, tap to reload data"
        let colorString = "reload data"
        let range = (mainString as NSString).range(of: colorString)
        let coloredString = NSMutableAttributedString.init(string: mainString)
        coloredString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(rgb: 0x2B3990), range: range)
        return coloredString
    }
    
    func isConnected() -> Bool {
        return NetworkManager.shared.isConnected()
    }
    
    let inetReachability = InternetReachability()!

    override func viewDidLoad(){
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged(note:)), name: Notification.Name.reachabilityChanged, object: inetReachability)

        do {
            try inetReachability.startNotifier()
        } catch {
            print("Could not start notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        inetReachability.stopNotifier()
    }

    @objc func internetChanged(note: Notification) {

        let noConnectionView = NoConnectionView.fromNib(nibName: "NoConnectionView")
        noConnectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 50, width: UIScreen.main.bounds.width - 40, height: 50)
        noConnectionView.tag = 101

        let reachability =  note.object as! InternetReachability

        //full of code
        switch reachability.connection {
        case .none:
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                let alert = UIAlertController(title: "No Connection Internet", message: "Oopppss, you're not connected to internet, please turn on your connection to continue", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Understand", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                self.baseDelegate?.noInternet()

                print("no internet")
            }
        case .cellular:
            DispatchQueue.main.async {
                self.baseDelegate?.hasInternet()
                print("connected to internet")
            }
        default:
            DispatchQueue.main.async {
                self.baseDelegate?.hasInternet()
                print("connected to internet")
            }
        }
    }
}
