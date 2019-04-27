//
//  AgreementsController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 26/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class AgreementsController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var buttonAgree: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        customView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        handleGestureListener()
    }
    
    private func customView() {
        buttonAgree.clipsToBounds = true
        buttonAgree.layer.cornerRadius = buttonAgree.frame.height / 2
    }
    
    private func handleGestureListener() {
        buttonAgree.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonAgreeClick)))
    }
}

//MARK: Handle gesture listener
extension AgreementsController {
    @objc func buttonAgreeClick() {
        performSegue(withIdentifier: "toHomeController", sender: self)
    }
}
