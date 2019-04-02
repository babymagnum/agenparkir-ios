//
//  SettingsController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 06/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin

protocol UpdateCurrentDataProtocol {
    func updateData()
}

class SettingsController: UIViewController, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconCancel: UIImageView!
    @IBOutlet weak var settingsCollectionView: UICollectionView!
    @IBOutlet weak var settingsCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var viewLogout: UIImageView!
    
    //MARK: Props
    var listSettings = [SettingsModel]()
    var delegate: UpdateCurrentDataProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        customView()
        
        initCollectionView()

        populateSettingsData()
        
        handleGestureListener()
    }
    
    private func handleGestureListener() {
        iconCancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconCancelClick)))
        viewLogout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewLogoutClick)))
        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(swipeBackGesture))
        swipeBack.direction = .right
        view.addGestureRecognizer(swipeBack)
    }
    
    private func customView() {
        viewLogout.clipsToBounds = true
        viewLogout.layer.cornerRadius = viewLogout.frame.width / 2
        PublicFunction().changeTintColor(imageView: iconCancel, hexCode: 0xb2bec3, alpha: 1.0)
    }
    
    private func populateSettingsData() {
        listSettings.append(SettingsModel("", "Account", 1))
        listSettings.append(SettingsModel("", "License Plate", 2))
        listSettings.append(SettingsModel("", "Languange", 3))
        listSettings.append(SettingsModel("", "Term of Service", 4))
        listSettings.append(SettingsModel("", "Website", 5))
        listSettings.append(SettingsModel("", "Privacy Police", 6))
        listSettings.append(SettingsModel("", "Password & PIN", 7))
        settingsCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.settingsCollectionHeight.constant = self.settingsCollectionView.contentSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    private func initCollectionView() {
        settingsCollectionView.delegate = self
        settingsCollectionView.dataSource = self
    }
    
    private func showDialog(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

//MARK: Handle Gesture Listener
extension SettingsController {
    @objc func iconCancelClick() {
        delegate?.updateData()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func viewLogoutClick() {
        SVProgressHUD.show()
        
        let logoutOperation = LogoutOperation()
        let operationQueue = OperationQueue()
        operationQueue.addOperation(logoutOperation)
        logoutOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                if let error = logoutOperation.error {
                    self.showDialog("Error Logout", error)
                    return
                }
                
                //set data has account, so when from welcome controller we can head to loginregister controller
                UserDefaults.standard.set(true, forKey: StaticVar.hasAccount)
                //set login state to false, so user will head to welcome controller first
                UserDefaults.standard.set(false, forKey: StaticVar.login)
                UserDefaults.standard.set("", forKey: StaticVar.id)
                UserDefaults.standard.set("", forKey: StaticVar.token)
                UserDefaults.standard.set("", forKey: StaticVar.images)
                
                if FBSDKAccessToken.current() != nil {
                    FBSDKAccessToken.setCurrent(nil)
                    FBSDKProfile.setCurrent(nil)
                    FBSDKLoginManager().logOut()
                }
                
                let welcomeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeController") as! WelcomeController
                self.present(welcomeController, animated: true)
            }
        }
    }
    
    @objc func swipeBackGesture() {
        delegate?.updateData()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func contentMainClick(sender: UITapGestureRecognizer) {
        if let indexPath = settingsCollectionView.indexPathForItem(at: sender.location(in: settingsCollectionView)) {
            
            switch listSettings[indexPath.item].id {
            case 1:
                let accountsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountsController") as! AccountsController
                self.navigationController?.pushViewController(accountsController, animated: true)
            case 2:
                let plateController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LicensePlateController") as! LicensePlateController
                self.navigationController?.pushViewController(plateController, animated: true)
            case 3:
                print("languange")
            case 4:
                print("tos")
            case 5:
                print("website")
            case 6:
                print("privacy policy")
            default:
                print("password")
            }
            
        }
    }
}

extension SettingsController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingsCell", for: IndexPath(item: 0, section: 0)) as! SettingsCell
        let width = UIScreen.main.bounds.width / 3 - 30
        let height = cell.contentMain.frame.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listSettings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.settingsData = listSettings[indexPath.item]
        cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentMainClick(sender:))))
        return cell
    }
}
