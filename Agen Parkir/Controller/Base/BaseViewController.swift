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

class BaseViewController: UIViewController {

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

                print("no internet")
            }
        case .cellular:
            DispatchQueue.main.async {
                print("connected to internet")
            }
        default:
            DispatchQueue.main.async {
                print("connected to internet")
            }
        }
    }
}
