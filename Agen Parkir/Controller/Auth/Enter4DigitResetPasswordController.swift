//
//  Enter4DigitResetPasswordController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 26/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

enum Enter4DigitCodeState {
    case password, email
}

class Enter4DigitResetPasswordController: BaseViewController, UITextFieldDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var viewIconBack: UIView!
    @IBOutlet weak var iconNext: UIImageView!
    @IBOutlet weak var input1: UITextField!
    @IBOutlet weak var input2: UITextField!
    @IBOutlet weak var input3: UITextField!
    @IBOutlet weak var input4: UITextField!
    @IBOutlet weak var resendCodePassword: UIButton!
    @IBOutlet weak var resendCodeEmail: UIButton!
    
    //MARK: Props
    var state: Enter4DigitCodeState?
    var email: String?
    var password: String?
    let bag = DisposeBag()
    var stateAllow = FormState.dont
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleGestureListener()
        
        bindUI()
    }
    
    private func bindUI() {
        Observable.combineLatest(input1.rx.text, input2.rx.text, input3.rx.text, input4.rx.text, resultSelector: {input1, input2, input3, input4 in
            
            if (input1?.count)! > 0 {
                self.input1.layer.borderColor = UIColor(rgb: 0x00A551).cgColor
            } else {
                self.input1.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            if (input2?.count)! > 0 {
                self.input2.layer.borderColor = UIColor(rgb: 0x00A551).cgColor
            } else {
                self.input2.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            if (input3?.count)! > 0 {
                self.input3.layer.borderColor = UIColor(rgb: 0x00A551).cgColor
            } else {
                self.input3.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            if (input4?.count)! > 0 {
                self.input4.layer.borderColor = UIColor(rgb: 0x00A551).cgColor
            } else {
                self.input4.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            if input1!.count > 0 && input2!.count > 0 && input3!.count > 0 && input4!.count > 0 {
                self.iconNext.image = UIImage(named: "Artboard 204@0.75x-8")
                self.stateAllow = .allow
            } else {
                self.stateAllow = .dont
                self.iconNext.image = UIImage(named: "Artboard 187@0.75x-8")
            }
            
        }).subscribe().disposed(by: bag)
    }
    
    private func handleGestureListener() {
        viewIconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewIconBackClick)))
        iconNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconNextClick)))
    }
    
    private func customView() {
        input1.layer.borderWidth = 1
        input2.layer.borderWidth = 1
        input3.layer.borderWidth = 1
        input4.layer.borderWidth = 1
        input1.layer.borderColor = UIColor.lightGray.cgColor
        input2.layer.borderColor = UIColor.lightGray.cgColor
        input3.layer.borderColor = UIColor.lightGray.cgColor
        input4.layer.borderColor = UIColor.lightGray.cgColor
        input1.layer.cornerRadius = 4
        input2.layer.cornerRadius = 4
        input3.layer.cornerRadius = 4
        input4.layer.cornerRadius = 4
        viewIconBack.layer.cornerRadius = viewIconBack.frame.width / 2
        PublicFunction.instance.changeTintColor(imageView: iconNext, hexCode: 0xffffff, alpha: 1.0)
        
        if let _ = state {
            if state == Enter4DigitCodeState.email {
                resendCodePassword.isHidden = true
                resendCodeEmail.isHidden = false
                textTitle.text = "Sign Up"
            } else {
                resendCodeEmail.isHidden = true
                resendCodePassword.isHidden = false
                textTitle.text = "Forgot Password"
            }
        }
    }
    
    private func showDialog(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

//MARK: Handle gesture listener
extension Enter4DigitResetPasswordController {
    @IBAction func resendButtonClick(_ sender: UIButton) {
        SVProgressHUD.show()
        let operationQueue = OperationQueue()
        let resendEmailOperation = ResendEmailOperation(email: UserDefaults.standard.string(forKey: StaticVar.email)!)
        operationQueue.addOperations([resendEmailOperation], waitUntilFinished: false)
        resendEmailOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            if let err = resendEmailOperation.error {
                self.showDialog("Error Resend Code", "with message \(err)")
                return
            }
            
            self.showDialog("Success Resend Code", resendEmailOperation.message!)
        }
    }
    
    @objc func viewIconBackClick() {
        print("back clicked")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func iconNextClick() {
        input1.resignFirstResponder()
        input2.resignFirstResponder()
        input3.resignFirstResponder()
        input4.resignFirstResponder()
        
        SVProgressHUD.show()
        
        let otp = "\(input1.text?.trim() ?? "")\(input2.text?.trim() ?? "")\(input3.text?.trim() ?? "")\(input4.text?.trim() ?? "")"
        let activationOperation = ActivationOperation(otp: otp)
        let loginOperation = LoginOperation(loginData: (email!, password!))
        loginOperation.addDependency(activationOperation)
        
        let operation = OperationQueue()
        operation.isSuspended = true
        operation.addOperation(activationOperation)
        operation.addOperation(loginOperation)
        operation.isSuspended = false
        
        activationOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            if let err = activationOperation.error {
                self.showDialog("Error Activation", "with message \(err)")
                return
            }
            
            if self.state == Enter4DigitCodeState.email {
                let alert = UIAlertController(title: "Email Activated", message: "Welcome to Agen Parkir", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Let's Go", style: .cancel, handler: { (UIAlertAction) in
                    UserDefaults.standard.set(true, forKey: StaticVar.login)
                    let agreementController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AgreementsController") as! AgreementsController
                    self.navigationController?.pushViewController(agreementController, animated: true)
                }))
                
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Success!!", message: "Your password was changed, you can login with your new password", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: { (UIAlertAction) in
                    for (index, item) in (self.navigationController?.viewControllers.enumerated())! {
                        
                        var viewControllerID = "\(item)".components(separatedBy: ":")
                        let clearViewControllerID = viewControllerID[0].replacingOccurrences(of: "<", with: "")
                        
                        var loginID = "\(LoginController())".components(separatedBy: ":")
                        let clearDvcID = loginID[0].replacingOccurrences(of: "<", with: "")
                        
                        if clearViewControllerID == clearDvcID {
                            self.navigationController?.popToViewController(self.navigationController?.viewControllers[index] as! LoginController, animated: true)
                            break
                        }
                    }
                }))
                
                self.present(alert, animated: true)
                
            }
        }
    }
}
