//
//  LoginController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import OneSignal
import FBSDKCoreKit
import FBSDKLoginKit
import SVProgressHUD

class LoginRegisterController: BaseViewController {

    //MARK: Outlet
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var arrowLogin: UIImageView!
    @IBOutlet weak var viewSignup: UIView!
    @IBOutlet weak var arrowSignup: UIImageView!
    @IBOutlet weak var viewFacebook: UIView!
    @IBOutlet weak var iconFacebook: UIImageView!
    @IBOutlet weak var viewGoogle: UIView!
    @IBOutlet weak var iconGoogle: UIImageView!
    
    var tapClicked = 0
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: StaticVar.login) {
            performSegue(withIdentifier: "toHomeController", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //uncoment below code if its dev
        //UserDefaults.standard.set("Dev", forKey: StaticVar.applicationState)
        UserDefaults.standard.set("Prod", forKey: StaticVar.applicationState)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        customView()
        
        handleGestureListener()
    }
    
    private func handleGestureListener() {
        viewLogin.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewLoginClick)))
        viewSignup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSignupClick)))
        viewFacebook.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewFacebookClick)))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick)))
    }
    
    private func customView(){
        iconFacebook.clipsToBounds = true
        iconGoogle.clipsToBounds = true
        viewLogin.layer.cornerRadius = viewLogin.frame.height / 2
        viewSignup.layer.cornerRadius = viewSignup.frame.height / 2
        PublicFunction.instance.changeTintColor(imageView: arrowLogin, hexCode: 0x4552FF, alpha: 1.0)
        PublicFunction.instance.changeTintColor(imageView: arrowSignup, hexCode: 0x4552FF, alpha: 1.0)
        iconGoogle.clipsToBounds = true
        iconGoogle.layer.cornerRadius = iconGoogle.frame.width / 2
        viewGoogle.layer.cornerRadius = viewGoogle.frame.height / 2
        viewFacebook.layer.cornerRadius = viewFacebook.frame.height / 2
    }
    
    private func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print("facebook token \(FBSDKAccessToken.current()?.tokenString ?? "")")
                    
                    let operation = OperationQueue()
                    let facebookLoginOperation = FacebookLoginOperation((FBSDKAccessToken.current()?.tokenString)!)
                    operation.addOperation(facebookLoginOperation)
                    facebookLoginOperation.completionBlock = {
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            switch facebookLoginOperation.state{
                            case .success?:
                                UserDefaults.standard.set(true, forKey: StaticVar.login)
                                let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as! HomeController
                                self.navigationController?.pushViewController(homeController, animated: true)
                            case .error?:
                                PublicFunction.instance.showUnderstandDialog(self, "Error Login", facebookLoginOperation.error!, "Understand")
                            default:
                                PublicFunction.instance.showUnderstandDialog(self, "Error Login", "There was some error with system, please try again", "Understand")
                            }
                        }
                    }
                }
            })
        }
    }
}

//MARK: Handle gesture listener
extension LoginRegisterController {
    @objc func viewFacebookClick() {
        SVProgressHUD.show()
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    SVProgressHUD.dismiss()
                    return
                }
                
                if(fbloginresult.grantedPermissions.contains("email")) {
                    self.getFBUserData()
                }
            }
        }
    }
    
    @objc func viewClick() {
        print("tap \(tapClicked)")
        tapClicked += 1
        
        if tapClicked == 15 {
            self.tapClicked = 0
            
            if UserDefaults.standard.string(forKey: StaticVar.applicationState) == "Dev" {
                UserDefaults.standard.set("Prod", forKey: StaticVar.applicationState)
                let alert = UIAlertController(title: "Production State", message: "You're in production state. All API will hit developing api url", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
                present(alert, animated: true)
            } else {
                UserDefaults.standard.set("Dev", forKey: StaticVar.applicationState)
                let alert = UIAlertController(title: "Developing State", message: "You're in developing state. All API will hit developing api url", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
                present(alert, animated: true)
            }
            
        }
    }
    
    @objc func viewLoginClick(){
        let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as! LoginController
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc func viewSignupClick(){
        let registerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterController") as! RegisterController
        navigationController?.pushViewController(registerController, animated: true)
    }
}
