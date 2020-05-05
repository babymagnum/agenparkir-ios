//
//  ChatController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 30/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import Alamofire
import SwiftyJSON

class ChatController: BaseViewController, UICollectionViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emptyText: UIButton!
    @IBOutlet weak var viewInputChat: UIView!
    @IBOutlet weak var inputChat: UITextField!
    @IBOutlet weak var iconAddImage: UIImageView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var opponentName: UILabel!
    
    //MARK: Props
    private var listChat = [ChatModel]()
    private var ref: DatabaseReference!
    private var userId = ""
    
    var buildingName: String?
    var buildingId: String?
    var orderId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userId = UserDefaults.standard.string(forKey: StaticVar.id) ?? ""
        ref = Database.database().reference()
        
        customView()
        
        initCollection()
        
        handleGesture()
        
        if let _orderId = orderId {
            getBuildingInfo(orderId: _orderId)
        } else {
            populateChat()
        }
    }
    
    private func handleGesture() {
        emptyText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyTextClick)))
        iconAddImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconAddImageClick)))
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick)))
    }
    
    private func customView() {
        inputChat.delegate = self
        PublicFunction.instance.changeTintColor(imageView: iconBack, hexCode: 0x00A551, alpha: 1.0)
        //PublicFunction.instance.changeTintColor(imageView: iconAddImage, hexCode: 0x00A551, alpha: 1.0)
        viewInputChat.layer.cornerRadius = viewInputChat.frame.height / 2
        viewInputChat.layer.borderWidth = 1
        viewInputChat.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func initCollection() {
        chatCollectionView.register(UINib(nibName: "MyChatCell", bundle: nil), forCellWithReuseIdentifier: "MyChatCell")
        chatCollectionView.register(UINib(nibName: "OpponentChatCell", bundle: nil), forCellWithReuseIdentifier: "OpponentChatCell")
        chatCollectionView.register(UINib(nibName: "MyChatImageCell", bundle: nil), forCellWithReuseIdentifier: "MyChatImageCell")
        chatCollectionView.register(UINib(nibName: "OpponentChatImageCell", bundle: nil), forCellWithReuseIdentifier: "OpponentChatImageCell")
        
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        chatCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func getBuildingInfo(orderId: Int) {
        SVProgressHUD.show()
        
        let operation = OperationQueue()
        let detailOngoingOperation = DetailOngoingOperation(order_id: orderId)
        operation.addOperation(detailOngoingOperation)
        detailOngoingOperation.completionBlock = {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                
                switch detailOngoingOperation.state{
                case .success?:
                    if let data = detailOngoingOperation.returnDetailOngoing {
                        
                        self.buildingId = "\(data.building_id)"
                        self.buildingName = data.building_name
                        
                        self.opponentName.text = self.buildingName
                        
                        self.populateChat()
                    }
                case .error?:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", detailOngoingOperation.error!, "Understand")
                default:
                    PublicFunction.instance.showUnderstandDialog(self, "Error", "There was something error with system, please refresh this page", "Understand")
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        chatCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func populateChat() {
        SVProgressHUD.show()
        
        ref.child("LIST_CHAT").child(buildingId ?? "").child(userId).child("CHATS").observe(.value) { dataSnapshot in
            SVProgressHUD.dismiss()
            
            self.listChat.removeAll()
            
            for snapshot in dataSnapshot.children {
                let _snapshot = snapshot as? DataSnapshot
                if let value = _snapshot?.value as? [String: Any] {
                    let chat = ChatModel(id: value["id"] as? String, message: value["message"] as? String, userId: value["userId"] as? String, isRead: value["read"] as? Bool, time: value["time"] as? Double, typeMessage: value["typeMessage"] as? String)
                    self.listChat.append(chat)
                }
            }
            
            self.listChat.sort { item1, item2 -> Bool in
                return item1.time ?? 0 < item2.time ?? 0
            }
            
            self.chatCollectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.chatCollectionView.scrollToLast()
            }
        }
    }
    
    private func sendNotification() {
        
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send?") else { return }
        
        let data: [String: String] = [
            "buildingId": buildingId ?? "",
            "customerId": userId,
            "customerName": UserDefaults.standard.string(forKey: StaticVar.name) ?? "",
            "title": "\(UserDefaults.standard.string(forKey: StaticVar.name) ?? "") mengirimkan pesan.",
            "body": inputChat.text?.trim() ?? "",
            "type": "chat"
        ]
        
        let body: [String : Any] = [
            "to": "fYBFnVEIQGOF3Z2CRQ-Vvg:APA91bFL5Ldm8CcVA4WGPOripJj0edRNQcYScI7nRsga8CPuHeaIP_1gw2D5luZGM1WCfTHfkdbkrRZroAisxQeRSCCMq93h9qcTPRvKfgsjTATlOhby4H43JVxcopX1pWfQQvATkcNK",
            "data": data
        ]
        
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "key=AAAAn19pgs8:APA91bFPWSp-7P7LIWyc88f2qd5IRqv7_ZskRh4ltSV6y4ExhY6YkO8OqcNugRKglP7rnjhAsj8bSapg6RdTkuFeHVpXCBvQhjpmSZmldyNu-Y10N6aQyHN9zYBeL2jK5uJinV-Bs5ct"
        ]
        
        Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(let responseSuccess):
                print("success send notification \(JSON(responseSuccess))")
            case .failure(let responseError):
                print("error send notification \(responseError.localizedDescription)")
                self.sendNotification()
            }
        }
    }
    
    private func checkDateCell(_ contentMainHeight: NSLayoutConstraint, _ index: Int, _ dateHeight: NSLayoutConstraint, _ dateLabel: UILabel) {
        let dateFull = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: listChat[index].time!)!, pattern: "dd MMMM yyyy")
        
        if index > 0 {
            let dateBeforeFull = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: listChat[index - 1].time!)!, pattern: "dd MMMM yyyy")
            let dateMonth = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: listChat[index].time!)!, pattern: "dd MMMM")
            let year = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: listChat[index].time!)!, pattern: "yyyy")
            let yearBefore = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: listChat[index - 1].time!)!, pattern: "yyyy")
            
            if dateFull == dateBeforeFull {
                dateLabel.text = ""
                dateHeight.constant = 0
            } else {
                if year != yearBefore {
                    dateLabel.text = dateFull
                    dateHeight.constant = 16
                } else {
                    dateLabel.text = dateMonth
                    dateHeight.constant = 16
                }
            }
        } else {
            dateLabel.text = dateFull
            dateHeight.constant = 16
        }
    }
    
    private func checkDateCellSize(_ messageLabel: UIButton, _ dateLabel: UILabel, _ index: Int) -> CGSize {
        let messageContent = listChat[index].message
        let approximateTextWidth = UIScreen.main.bounds.width - 98
        let size = CGSize(width: approximateTextWidth, height: 1000)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let estimatedFrame = NSString(string: messageContent!).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let originalSize = estimatedFrame.height + 10 + dateLabel.frame.height + 14 + 9 /* 10 untuk margin dan 14 untuk padding */
        let withoutDateSize = estimatedFrame.height + 5 + 14 + 9 /* 5 untuk margin dan 14 untuk padding */
        
        if index > 0 {
            let date = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: listChat[index].time!)!, pattern: "dd MMMM yyyy")
            let dateBefore = PublicFunction.instance.dateLongToString(dateInMillis: Double(exactly: listChat[index - 1].time!)!, pattern: "dd MMMM yyyy")
            
            if date == dateBefore {
                return CGSize(width: UIScreen.main.bounds.width, height: withoutDateSize)
            } else {
                return CGSize(width: UIScreen.main.bounds.width, height: originalSize)
            }
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: originalSize - 4)
        }
    }
    
    private func sendMessage() {
        let uuid = NSUUID().uuidString.lowercased()
        let time = PublicFunction().getCurrentMillisecond(pattern: "dd MMMM yyyy HH:mm:ss")
        let body: [String: Any] = [
            "id": userId,
            "name": UserDefaults.standard.string(forKey: StaticVar.name) ?? "",
            "time": time,
            "message": inputChat.text?.trim() ?? ""
        ]
        
        let bodyMessage: [String: Any] = [
            "id": uuid,
            "message": inputChat.text?.trim() ?? "",
            "userId": userId,
            "read": false,
            "time": time,
            "typeMessage": StaticVar.userMessage
        ]
        
        if listChat.count == 0 {
            ref.child("LIST_CHAT").child(buildingId ?? "").child(userId).setValue(body) { error, _ in
                if let _error = error {
                  print("Data could not be saved: \(_error).")
                } else {
                    self.ref.child("LIST_CHAT").child(self.buildingId ?? "").child(self.userId).child("CHATS")
                        .child(uuid).setValue(bodyMessage) { err, _ in
                            if let _err = err {
                                print(_err.localizedDescription)
                            } else {
                                self.sendNotification()
                                self.inputChat.text = ""
                            }
                    }
                }
            }
        } else {
            ref.child("LIST_CHAT").child(buildingId ?? "").child(userId).updateChildValues(body) { error, _ in
                if let _error = error {
                  print("Data could not be saved: \(_error).")
                } else {
                    self.ref.child("LIST_CHAT").child(self.buildingId ?? "").child(self.userId).child("CHATS")
                        .child(uuid).setValue(bodyMessage) { err, _ in
                            if let _err = err {
                                print(_err.localizedDescription)
                            } else {
                                self.sendNotification()
                                self.inputChat.text = ""
                            }
                    }
                }
            }
        }
    }
}

//MARK: Handle Gesture
extension ChatController {
    @objc func emptyTextClick() {
    }
    
    @objc func iconAddImageClick() {
        sendMessage()
//        ImagePickerManager().pickImage(self) { (image, url) in
//            let imagePreviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewController") as! ImagePreviewController
//            imagePreviewController.imageUrl = url
//            imagePreviewController.imagePicked = image
//            imagePreviewController.delegate = self
//            self.present(imagePreviewController, animated: true)
//        }
    }
    
    @objc func iconBackClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func viewClick() {
        inputChat.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            //inputChat.becomeFirstResponder()
            self.sendMessage()
        }
        
        return true
    }
}

//MARK: Collectionview
extension ChatController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listChat.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if listChat[indexPath.row].typeMessage == StaticVar.userMessage && listChat[indexPath.row].userId == userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatCell", for: indexPath) as! MyChatCell
            cell.dataMessage = listChat[indexPath.row]
            self.checkDateCell(cell.contentMainHeight, indexPath.row, cell.dateHeight, cell.date)
            return cell
        } else if listChat[indexPath.row].typeMessage == StaticVar.userMessage && listChat[indexPath.row].userId != userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentChatCell", for: indexPath) as! OpponentChatCell
            cell.dataMessage = listChat[indexPath.row]
            self.checkDateCell(cell.contentMainHeight, indexPath.row, cell.dateHeight, cell.date)
            return cell
        } else if listChat[indexPath.row].typeMessage == StaticVar.fileMessage && listChat[indexPath.row].userId == userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatImageCell", for: indexPath) as! MyChatImageCell
            cell.dataMessage = listChat[indexPath.row]
            self.checkDateCell(cell.contentMainHeight, indexPath.row, cell.dateHeight, cell.date)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentChatImageCell", for: indexPath) as! OpponentChatImageCell
            cell.dataMessage = listChat[indexPath.row]
            self.checkDateCell(cell.contentMainHeight, indexPath.row, cell.dateHeight, cell.date)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if listChat[indexPath.row].typeMessage == StaticVar.userMessage && listChat[indexPath.row].userId == userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatCell", for: indexPath) as! MyChatCell
            return self.checkDateCellSize(cell.message, cell.date, indexPath.row)
        } else if listChat[indexPath.row].typeMessage == StaticVar.userMessage && listChat[indexPath.row].userId != userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentChatCell", for: indexPath) as! OpponentChatCell
            return self.checkDateCellSize(cell.message, cell.date, indexPath.row)
        } else if listChat[indexPath.row].typeMessage == StaticVar.fileMessage && listChat[indexPath.row].userId == userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatImageCell", for: indexPath) as! MyChatImageCell
            return CGSize(width: UIScreen.main.bounds.width, height: cell.date.frame.height + 30 + cell.image.frame.height + 9)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentChatImageCell", for: indexPath) as! OpponentChatImageCell
            return CGSize(width: UIScreen.main.bounds.width, height: cell.date.frame.height + 30 + cell.image.frame.height + 9)
        }
    }
}
