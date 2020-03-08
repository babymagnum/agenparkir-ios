//
//  AccountsController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 06/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import FBSDKCoreKit

class AccountsController: BaseViewController, UITextFieldDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var accountScrollView: UIScrollView!
    @IBOutlet weak var iconEdit: UIImageView!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputPhone: UITextField!
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var iconEditImage: UIImageView!
    
    //props
    var edit = false
    var popRecognizer: InteractivePopRecognizer?
    var imageURL = ""
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()
        
        customView()

        handleGestureListener()
        
        populateDefaultData()
    }        
    
    private func customView() {
        accountScrollView.addSubview(refreshControl)
        
        inputName.tag = 1
        inputName.delegate = self
        imageUser.clipsToBounds = true
        imageUser.layer.cornerRadius = imageUser.frame.width / 2
        viewEdit.clipsToBounds = true
        viewEdit.layer.cornerRadius = viewEdit.frame.width / 2
        PublicFunction.instance.changeTintColor(imageView: iconEditImage, hexCode: 0xffffff, alpha: 1)
        PublicFunction.instance.changeTintColor(imageView: iconBack, hexCode: 0x000000, alpha: 0.8)
        PublicFunction.instance.changeTintColor(imageView: iconEdit, hexCode: 0x000000, alpha: 0.8)
    }
    
    private func populateDefaultData() {
        inputName.text = UserDefaults.standard.string(forKey: StaticVar.name)
        inputPhone.text = UserDefaults.standard.string(forKey: StaticVar.phone)
        if AccessToken.current != nil {
            inputEmail.text = "\(UserDefaults.standard.string(forKey: StaticVar.email)?.dropFirst(3) ?? "")"
        } else {
            inputEmail.text = UserDefaults.standard.string(forKey: StaticVar.email)
        }
        
        if UserDefaults.standard.string(forKey: StaticVar.images) == "" {
            self.imageUser.image = UIImage(named: "Artboard 123@0.75x-8")
        } else {
            let root_image_customer = "https://s3-ap-southeast-1.amazonaws.com/mika-park1/"
            self.imageUser.kf.setImage(with: URL(string: "\(root_image_customer)\(UserDefaults.standard.string(forKey: StaticVar.images) ?? "")"))
        }
    }
    
    private func handleGestureListener() {
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        iconEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconEditClick)))
        viewEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewEditClick)))
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
}

//MARK: Handle Gesture Listener
extension AccountsController {
    @objc func viewEditClick() {
        ImagePickerManager().pickImage(self) { (image, url) in
            print("image url picked \(url.lastPathComponent)")
            self.imageURL = url.lastPathComponent
            self.imageUser.image = image
        }
    }
    
    @objc func iconEditClick() {
        if !edit {
            edit = true
            inputName.isEnabled = true
            viewEdit.isHidden = false
            inputName.textColor = UIColor.black
            iconEdit.image = UIImage(named: "Artboard 235@0.75x-8")
        } else {
            SVProgressHUD.show()
            
            edit = false
            inputName.isEnabled = false
            viewEdit.isHidden = true
            inputName.textColor = UIColor.lightGray
            iconEdit.image = UIImage(named: "edit")
            
            //save data
            let accountOperation = AccountOperation((name: (inputName.text?.trim())!, imageUrl: imageURL, imageData: imageUser.image!))
            let operationQueue = OperationQueue()
            operationQueue.addOperation(accountOperation)
            accountOperation.completionBlock = {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if let _ = accountOperation.error { return }
                    
                    PublicFunction.instance.showUnderstandDialog(self, "Success Edit", "Your profile was edited successfully", "Understand")
                    
                    UserDefaults.standard.set(true, forKey: StaticVar.reload_home_controller)
                }
            }
        }
    }
    
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            inputName.resignFirstResponder()
        }
        
        return true
    }
    
    @objc func handleRefresh(_ refreshController: UIRefreshControl) {
        populateDefaultData()
        
        refreshController.endRefreshing()
    }
}
