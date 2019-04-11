//
//  LoginController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxCocoa
import RxSwift

enum LoginState {
    case allow, dont
}

class LoginController: BaseViewController, UITextFieldDelegate {

    //MARK: Outlet
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var viewNext: UIView!
    @IBOutlet weak var iconNext: UIImageView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var lineEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var linePassword: UIView!
    @IBOutlet weak var iconForgotPassword: UIImageView!
    @IBOutlet weak var viewForgotPassword: UIView!
    @IBOutlet weak var iconDeleteEmail: UIImageView!
    
    //MARK: Props
    private var state = LoginState.dont
    private var passwordShow = false
    fileprivate let bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        initTextfieldDelegate()

        handleGestureListener()
        
        bindUI()
    }
    
    private func bindUI() {
        Observable.combineLatest(inputEmail.rx.text, inputPassword.rx.text, resultSelector: {
            currentEmail, currentPassword in
            
            if currentEmail!.count > 0 {
                self.iconDeleteEmail.isHidden = false
                self.inputEmail.textColor = UIColor(rgb: 0x008F45)
                self.lineEmail.backgroundColor = UIColor(rgb: 0x008F45)
            } else {
                self.iconDeleteEmail.isHidden = true
                self.inputEmail.textColor = UIColor.lightGray
                self.lineEmail.backgroundColor = UIColor.lightGray
            }
            
            if currentPassword!.count > 5 {
                self.inputPassword.textColor = UIColor(rgb: 0x008F45)
                self.linePassword.backgroundColor = UIColor(rgb: 0x008F45)
            } else {
                self.inputPassword.textColor = UIColor.lightGray
                self.linePassword.backgroundColor = UIColor.lightGray
            }
            
            if currentEmail!.count > 0 && currentPassword!.count > 0 {
                self.viewNext.backgroundColor = UIColor(rgb: 0x008F45)
                self.state = .allow
            } else {
                self.viewNext.backgroundColor = UIColor.lightGray
                self.state = .dont
            }
            
        })
        .subscribe().disposed(by: bag)
    }
    
    private func initTextfieldDelegate() {
        inputEmail.delegate = self
        inputPassword.delegate = self
        inputEmail.tag = 1
        inputPassword.tag = 2
    }
    
    private func handleGestureListener() {
        viewLogin.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewLoginClick)))
        iconDeleteEmail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconDeleteEmailClick)))
        viewForgotPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewForgotPasswordClick)))
        viewNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewNextClick)))
    }
    
    private func customView() {
        viewEmail.layer.cornerRadius = 4
        viewEmail.layer.shadowColor = UIColor.black.cgColor
        viewEmail.layer.shadowOffset = CGSize(width: 2.5, height: 5)
        viewEmail.layer.shadowRadius = 5
        viewEmail.layer.shadowOpacity = 0.7
        
        viewPassword.layer.cornerRadius = 4
        viewPassword.layer.shadowColor = UIColor.black.cgColor
        viewPassword.layer.shadowOffset = CGSize(width: 2.5, height: 5)
        viewPassword.layer.shadowRadius = 5
        viewPassword.layer.shadowOpacity = 0.7
        
        viewLogin.layer.cornerRadius = 25
        viewLogin.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        viewNext.layer.cornerRadius = viewNext.frame.width / 2
        
        PublicFunction().changeTintColor(imageView: iconDeleteEmail, hexCode: 0x000000, alpha: 0.6)
        PublicFunction().changeTintColor(imageView: iconNext, hexCode: 0xffffff, alpha: 1.0)
        PublicFunction().changeTintColor(imageView: iconForgotPassword, hexCode: 0x00A551, alpha: 1.0)
        
        /*
         bottom_right = .layerMaxXMaxYCorner
         bottom_left = .layerMinXMaxYCorner
         top_right = .layerMaxXMinYCorner
         top_left = .layerMinXMinYCorner
        */
    }
    
    private func showDialog(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

//MARK: Handle gesture listeter
extension LoginController {
    @objc func viewForgotPasswordClick() {
        let forgotPasswordController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordController") as! ForgotPasswordController
        navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    @objc func iconDeleteEmailClick() {
        inputEmail.text = ""
    }
    
    @objc func viewNextClick() {
        if state == .dont {
            PublicFunction().showUnderstandDialog(self, "Form Not Complete", "Make sure to input your email and password before login", "Understand")
            return
        }
        
        inputEmail.resignFirstResponder()
        inputPassword.resignFirstResponder()
        
        SVProgressHUD.show()
        
        let email = inputEmail.text?.trim()
        let password = inputPassword.text?.trim()
        UserDefaults.standard.set(email, forKey: StaticVar.email)
        
        let operationQueue = OperationQueue()
        let loginOperation = LoginOperation(loginData: (email!, password!))
        operationQueue.addOperation(loginOperation)
        loginOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            if let err = loginOperation.error {
                
                let alert = UIAlertController(title: "Login Error", message: err, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Activate", style: .default, handler: { (UIAlertAction) in
                    
                    SVProgressHUD.show()
                    
                    let resendEmailOperation = ResendEmailOperation(email: (self.inputEmail.text?.trim())!)
                    
                    operationQueue.addOperation(resendEmailOperation)
                    
                    resendEmailOperation.completionBlock = {
                        SVProgressHUD.dismiss()
                        
                        if let err = resendEmailOperation.error {
                            PublicFunction().showUnderstandDialog(self, "Error Activate Email", err, "Understand")
                            return
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                            let enter4digit = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Enter4DigitResetPasswordController") as! Enter4DigitResetPasswordController
                            enter4digit.state = Enter4DigitCodeState.email
                            enter4digit.email = email
                            enter4digit.password = password
                            self.navigationController?.pushViewController(enter4digit, animated: true)
                        })
                    }
                }))
                self.present(alert, animated: true)
                
                return
            }
            
            UserDefaults.standard.set(true, forKey: StaticVar.login)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeController") as! HomeController
                self.navigationController?.pushViewController(homeController, animated: true)
            })
        }
    }
    
    @IBAction func showButtonClick(_ sender: UIButton) {
        if !passwordShow {
            passwordShow = !passwordShow
            sender.setTitle("Hide", for: .normal)
            inputPassword.isSecureTextEntry = false
        } else {
            passwordShow = !passwordShow
            sender.setTitle("Show", for: .normal)
            inputPassword.isSecureTextEntry = true
        }
    }
    
    @objc func viewLoginClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            DispatchQueue.main.async {
                self.inputEmail.resignFirstResponder()
                self.inputPassword.becomeFirstResponder()
            }
        } else {
            DispatchQueue.main.async {
                self.inputPassword.resignFirstResponder()
            }
        }
        
        return true
    }
}
