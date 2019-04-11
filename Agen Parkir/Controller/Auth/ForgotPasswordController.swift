//
//  ForgotPasswordController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa

class ForgotPasswordController: BaseViewController, UITextFieldDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var viewIconBack: UIView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var iconDeleteEmail: UIImageView!
    @IBOutlet weak var viewNext: UIImageView!
    @IBOutlet weak var lineEmail: UIView!
    @IBOutlet weak var viewEmail: UIView!
    
    //MARK: Props
    private var state = BehaviorRelay(value: FormState.dont)
    let bag = DisposeBag()
    let defaultObs = BehaviorRelay(value: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        customView()
        
        handleGestureListener()
        
        bindUI()
    }
    
    private func bindUI() {
        Observable.combineLatest(inputEmail.rx.text, defaultObs.asObservable(), resultSelector: { inputEmail, defaultObs in
            if inputEmail!.count > 0 {
                self.lineEmail.backgroundColor = UIColor(rgb: 0x00A551)
                self.inputEmail.textColor = UIColor(rgb: 0x00A551)
                self.state.accept(.allow)
            } else {
                self.lineEmail.backgroundColor = UIColor.lightGray
                self.state.accept(.dont)
            }
            
        }).subscribe().disposed(by: bag)
    }
    
    private func handleGestureListener() {
        viewIconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewIconBackClick)))
        viewNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewNextClick)))
    }
    
    private func customView() {
        inputEmail.delegate = self
        inputEmail.tag = 1
        viewIconBack.layer.cornerRadius = viewIconBack.frame.width / 2
        viewNext.layer.cornerRadius = viewNext.frame.width / 2
        viewEmail.layer.cornerRadius = 4
        viewEmail.layer.shadowColor = UIColor.black.cgColor
        viewEmail.layer.shadowOffset = CGSize(width: 2, height: 4)
        viewEmail.layer.shadowRadius = 4
        viewEmail.layer.shadowOpacity = 0.7
    }
    
    private func showDialog(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

//MARK: Handle gesture listener
extension ForgotPasswordController {
    @objc func viewIconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func viewNextClick() {
        if state.value == .dont {
            PublicFunction().showUnderstandDialog(self, "Empty Email", "Please input registered email, so we can send link to reset your password", "Understand")
            return
        }
        
        inputEmail.resignFirstResponder()
        
        SVProgressHUD.show()
        
        let operationQueue = OperationQueue()
        let forgotPasswordOperation = ForgotPasswordOperation(email: (inputEmail.text?.trim())!)
        operationQueue.addOperations([forgotPasswordOperation], waitUntilFinished: false)
        forgotPasswordOperation.completionBlock = {
            SVProgressHUD.dismiss()
            
            if let err = forgotPasswordOperation.error {
                self.showDialog("Error!!", err)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                //self.showDialog("Reset Password", forgotPasswordOperation.message!)
                
                let alert = UIAlertController(title: "Reset Password", message: forgotPasswordOperation.message, preferredStyle: .alert)
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
                
//                let enter4DigitController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Enter4DigitResetPasswordController") as! Enter4DigitResetPasswordController
//                enter4DigitController.state = Enter4DigitCodeState.password
//                self.navigationController?.pushViewController(enter4DigitController, animated: true)
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            inputEmail.textColor = UIColor.green
            lineEmail.backgroundColor = UIColor.green
            inputEmail.resignFirstResponder()
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            if range.length == 1 { //delete single string
                inputEmail.textColor = UIColor.lightGray
                lineEmail.backgroundColor = UIColor.lightGray
            } else if range.length > 1 { //delete whole string
                inputEmail.textColor = UIColor.lightGray
                lineEmail.backgroundColor = UIColor.lightGray
            }
        }
        
        return true
    }
}
