//
//  RegisterController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 26/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

class RegisterController: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var viewNext: UIView!
    @IBOutlet weak var iconNext: UIImageView!
    @IBOutlet weak var viewFullName: UIView!
    @IBOutlet weak var inputFullName: UITextField!
    @IBOutlet weak var lineFullName: UIView!
    @IBOutlet weak var iconDeleteFullName: UIImageView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var lineEmail: UIView!
    @IBOutlet weak var iconDeleteEmail: UIImageView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var linePassword: UIView!
    @IBOutlet weak var buttonTooglePassword: UIButton!
    @IBOutlet weak var viewConfirmPassword: UIView!
    @IBOutlet weak var inputConfirmPassword: UITextField!
    @IBOutlet weak var buttonToogleConfirmPassword: UIButton!
    @IBOutlet weak var lineConfirmPassword: UIView!
    @IBOutlet weak var viewPhoneNumber: UIView!
    @IBOutlet weak var inputPhoneNumber: UITextField!
    @IBOutlet weak var linePhoneNumber: UIView!
    @IBOutlet weak var iconDeletePhoneNumber: UIImageView!
    
    //MARK: Props
    fileprivate let bag = DisposeBag()
    var passwordShow = false
    var confirmPasswordShow = false
    var state = FormState.dont
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)

        handleGestureListener()
        
        bindUI()
    }
    
    private func handleGestureListener() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick)))
        viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewBackClick)))
        viewNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewNextClick)))
        iconDeleteFullName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconDeleteFullNameClick)))
        iconDeleteEmail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconDeleteEmailClick)))
        buttonTooglePassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTooglePasswordClick)))
        buttonToogleConfirmPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonToogleConfirmPasswordClick)))
        iconDeletePhoneNumber.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconDeletePhoneNumberClick)))
    }
    
    private func bindUI() {
        Observable.combineLatest(inputFullName.rx.text, inputEmail.rx.text, inputPassword.rx.text, inputConfirmPassword.rx.text, inputPhoneNumber.rx.text, resultSelector: { name, email, password, confirmPassword, phone in
            
            if (name?.count)! > 5 {
                self.changeToGreen(self.inputFullName, self.lineFullName)
                self.iconDeleteFullName.isHidden = false
            } else {
                self.changeToDefault(self.inputFullName, self.lineFullName)
                self.iconDeleteFullName.isHidden = true
            }
            
            if (email?.contains("@"))! {
                self.changeToGreen(self.inputEmail, self.lineEmail)
                self.iconDeleteEmail.isHidden = false
            } else {
                self.changeToDefault(self.inputEmail, self.lineEmail)
                self.iconDeleteEmail.isHidden = true
            }
            
            if (password?.count)! > 5  {
                self.changeToGreen(self.inputPassword, self.linePassword)
            } else {
                self.changeToDefault(self.inputPassword, self.linePassword)
            }
            
            if confirmPassword == password && confirmPassword != "" {
                self.changeToGreen(self.inputConfirmPassword, self.lineConfirmPassword)
            } else {
                self.changeToDefault(self.inputConfirmPassword, self.lineConfirmPassword)
            }
            
            if (phone?.count)! > 11 {
                self.changeToGreen(self.inputPhoneNumber, self.linePhoneNumber)
                self.iconDeletePhoneNumber.isHidden = false
            } else {
                self.changeToDefault(self.inputPhoneNumber, self.linePhoneNumber)
                self.iconDeletePhoneNumber.isHidden = true
            }
            
            if (name?.count)! > 0 && (email?.count)! > 0 && (password?.count)! > 0 && (confirmPassword?.count)! > 0 && (phone?.count)! > 0 {
                self.viewNext.backgroundColor = UIColor(rgb: 0x008F45)
                self.state = .allow
            } else {
                self.viewNext.backgroundColor = UIColor.lightGray
                self.state = .dont
            }
            
        }).subscribe().disposed(by: bag)
    }
    
    private func customView() {
        PublicFunction().changeTintColor(imageView: iconNext, hexCode: 0xffffff, alpha: 1.0)
        viewBack.layer.cornerRadius = 25
        viewBack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        viewNext.layer.cornerRadius = viewNext.frame.width / 2
        inputFullName.delegate = self
        inputEmail.delegate = self
        inputPassword.delegate = self
        inputConfirmPassword.delegate = self
        inputPhoneNumber.delegate = self
        inputFullName.tag = 1
        inputEmail.tag = 2
        inputPassword.tag = 3
        inputConfirmPassword.tag = 4
        inputPhoneNumber.tag = 5
        PublicFunction().setShadow(viewFullName, 4, UIColor.lightGray.cgColor, 2, 4, 4, 1.0)
        PublicFunction().setShadow(viewEmail, 4, UIColor.lightGray.cgColor, 2, 4, 4, 1.0)
        PublicFunction().setShadow(viewPassword, 4, UIColor.lightGray.cgColor, 2, 4, 4, 1.0)
        PublicFunction().setShadow(viewConfirmPassword, 4, UIColor.lightGray.cgColor, 2, 4, 4, 1.0)
        PublicFunction().setShadow(viewPhoneNumber, 4, UIColor.lightGray.cgColor, 2, 4, 4, 1.0)
    }
    
    private func showDialog(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func changeToGreen(_ textField: UITextField, _ line: UIView) {
        textField.textColor = UIColor(rgb: 0x008F45)
        line.backgroundColor = UIColor(rgb: 0x008F45)
    }
    
    private func changeToDefault(_ textField: UITextField, _ line: UIView) {
        textField.textColor = UIColor.lightGray
        line.backgroundColor = UIColor.lightGray
    }
    
    private func hideKeyboard() {
        DispatchQueue.main.async {
            self.inputPassword.resignFirstResponder()
            self.inputFullName.resignFirstResponder()
            self.inputEmail.resignFirstResponder()
            self.inputConfirmPassword.resignFirstResponder()
            self.inputPhoneNumber.resignFirstResponder()
        }
    }
}

//MARK: Handle gesture listener
extension RegisterController {
    @objc func iconDeletePhoneNumberClick() {
        inputPhoneNumber.text = ""
    }
    
    @objc func buttonToogleConfirmPasswordClick() {
        if !confirmPasswordShow {
            self.confirmPasswordShow = !confirmPasswordShow
            buttonToogleConfirmPassword.setTitle("Hide", for: .normal)
            self.inputConfirmPassword.isSecureTextEntry = false
        } else {
            self.confirmPasswordShow = !confirmPasswordShow
            buttonToogleConfirmPassword.setTitle("Show", for: .normal)
            self.inputConfirmPassword.isSecureTextEntry = true
        }
    }
    
    @objc func buttonTooglePasswordClick() {
        if !passwordShow {
            self.passwordShow = !passwordShow
            buttonTooglePassword.setTitle("Hide", for: .normal)
            self.inputPassword.isSecureTextEntry = false
        } else {
            self.passwordShow = !passwordShow
            buttonTooglePassword.setTitle("Show", for: .normal)
            self.inputPassword.isSecureTextEntry = true
        }
    }
    
    @objc func iconDeleteEmailClick() {
        inputEmail.text = ""
    }
    
    @objc func iconDeleteFullNameClick() {
        inputFullName.text = ""
    }
    
    @objc func viewNextClick() {
        if state == .dont {
            PublicFunction().showUnderstandDialog(self, "Form Not Complete", "Make sure to fill the registration form before procceed", "Understand")
            return
        }
        
        hideKeyboard()
        
        SVProgressHUD.show()
        
        let fullName = inputFullName.text?.trim()
        let email = inputEmail.text?.trim()
        let password = inputPassword.text?.trim()
        let phoneNumber = inputPhoneNumber.text?.trim()
        UserDefaults.standard.set(email, forKey: "email")
        
        let operation = OperationQueue()
        let registerOperation = RegisterOperation(registerModel: RegisterModel(fullName: fullName!, email: email!, password: password!, phone: phoneNumber!))
        operation.addOperations([registerOperation], waitUntilFinished: false)

        registerOperation.completionBlock = {
            SVProgressHUD.dismiss()

            if let err = registerOperation.error {
                self.showDialog("Error Creating Account", "with message \(err)")
                return
            }

            //to screen enter4digit
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03, execute: {
                let enter4digit = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Enter4DigitResetPasswordController") as! Enter4DigitResetPasswordController
                enter4digit.state = Enter4DigitCodeState.email
                enter4digit.email = email
                enter4digit.password = password
                self.navigationController?.pushViewController(enter4digit, animated: true)
            })
        }
    }
    
    @objc func viewBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func viewClick() {
        hideKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            DispatchQueue.main.async {
                self.inputFullName.resignFirstResponder()
                self.inputEmail.becomeFirstResponder()
            }
        case 2:
            DispatchQueue.main.async {
                self.inputEmail.resignFirstResponder()
                self.inputPassword.becomeFirstResponder()
            }
        case 3:
            DispatchQueue.main.async {
                self.inputPassword.resignFirstResponder()
                self.inputConfirmPassword.becomeFirstResponder()
            }
        case 4:
            DispatchQueue.main.async {
                self.inputConfirmPassword.resignFirstResponder()
                self.inputPhoneNumber.becomeFirstResponder()
            }
        default:
            DispatchQueue.main.async {
                self.inputPhoneNumber.resignFirstResponder()
                self.viewNext.backgroundColor = UIColor(rgb: 0x008F45)
            }
        }
        
        return true
    }
}
