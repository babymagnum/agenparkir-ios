//
//  ChatController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 30/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SendBirdSDK
import RxSwift
import RxCocoa
import SVProgressHUD

class ChatController: UIViewController, UICollectionViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var viewInputChat: UIView!
    @IBOutlet weak var inputChat: UITextField!
    @IBOutlet weak var iconAddImage: UIImageView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var opponentStatus: UILabel!
    
    //MARK: Props
    var listChat = [ChatModel]()
    var userId: String? //for creating channel
    var thisChannel: SBDGroupChannel?
    var defaultObservable = BehaviorRelay(value: "")
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customView()
        
        initCollection()
        
        joinChannelWithId()
        
        checkOnlineStatus()
        
        handleGesture()
        
        bindUI()
    }
    
    private func checkOnlineStatus() {
        self.checkOpponentStatus { (isOnline, lastSeen, name) in
            self.opponentName.text = name
            
            if isOnline {
                self.opponentStatus.text = "Online"
            } else {
                self.opponentStatus.text = "Last seen at \(lastSeen)"
            }
        }
    }
    
    private func bindUI() {
        Observable.combineLatest(inputChat.rx.text, defaultObservable.asObservable(), resultSelector: {
            chat, defaultObs in
            
            if (chat?.count)! > 0 {
                self.thisChannel?.startTyping()
            } else {
                self.thisChannel?.endTyping()
            }
            
        }).subscribe().disposed(by: bag)
    }
    
    private func joinChannelWithId() {
        SBDGroupChannel.createChannel(withUserIds: ["user1"], isDistinct: true) { (channel, error) in
            if let err = error {
                PublicFunction().showUnderstandDialog(self, "Error Join Channel", err.localizedDescription, "Understand")
                return
            }
            
            self.thisChannel = channel
            
            SBDMain.add(self as SBDChannelDelegate, identifier: ((channel?.channelUrl)!))
            
            self.populateData(channel!)
        }
    }
    
    private func checkOpponentStatus(completionHandler: @escaping (_ isOnline: Bool, _ lastOnline: String, _ name: String) -> Void) {
        let applicationUserListQuery = SBDMain.createApplicationUserListQuery()
        applicationUserListQuery?.userIdsFilter = ["user1"]
        applicationUserListQuery?.loadNextPage(completionHandler: { (users, error) in
            guard error == nil else {return}
            
            if users?[0].connectionStatus == SBDUserConnectionStatus.online {
                completionHandler(true, PublicFunction().dateLongToString(dateInMillis: Double(exactly: (users?[0].lastSeenAt)!)!, pattern: "dd MMM yyyy / kk:mm"), (users?[0].nickname)!)
            } else if users?[0].connectionStatus == SBDUserConnectionStatus.offline {
                completionHandler(false, PublicFunction().dateLongToString(dateInMillis: Double(exactly: (users?[0].lastSeenAt)!)!, pattern: "dd MMM yyyy / kk:mm"), (users?[0].nickname)!)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //remove sendbird delegate if view disappear
        SBDMain.removeChannelDelegate(forIdentifier: (thisChannel?.channelUrl)!)
    }
    
    private func handleGesture() {
        iconAddImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconAddImageClick)))
        iconBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconBackClick)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func customView() {
        inputChat.tag = 1
        inputChat.delegate = self
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x00A551, alpha: 1.0)
        PublicFunction().changeTintColor(imageView: iconAddImage, hexCode: 0x00A551, alpha: 1.0)
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
    
    private func populateData(_ channel: SBDGroupChannel) {
        SVProgressHUD.show()
        
        let previousMessageQuery = channel.createPreviousMessageListQuery()
        previousMessageQuery?.loadPreviousMessages(withLimit: 30, reverse: false, completionHandler: { (messages, error) in
            if let err = error {
                print("error failed last message \(err.localizedDescription)")
                return
            }
            
            if messages?.count == 0 {
                PublicFunction().showUnderstandDialog(self, "Empty Chat", "Ask anything to this store by typing chat in bottom of screen", "Understand")
                SVProgressHUD.dismiss()
                return
            }
            
            self.listChat.removeAll()
            
            for (index, message) in (messages?.enumerated())! {
                if message is SBDUserMessage {
                    guard let userMessage = message as? SBDUserMessage else {return}
                    self.listChat.append(ChatModel(userMessage.messageId, userMessage.message!, userMessage.createdAt, (userMessage.sender?.userId)!, .text))
                } else if message is SBDFileMessage {
                    guard let fileMessage = message as? SBDFileMessage else {return}
                    self.listChat.append(ChatModel(fileMessage.messageId, fileMessage.url, fileMessage.createdAt, (fileMessage.sender?.userId)!, .image))
                } else if message is SBDAdminMessage {
                    print("admin message")
                }
                
                if index == (messages?.count)! - 1 {
                    SVProgressHUD.dismiss()
                    
                    self.chatCollectionView.reloadData()
                    
                    //let bottomOffset = CGPoint(x: 0, y: self.chatCollectionView.contentSize.height)
                    //self.chatCollectionView.setContentOffset(bottomOffset, animated: true)
                }
            }
        })
    }
    
    private func checkDateCell(_ contentMainHeight: NSLayoutConstraint, _ index: Int, _ dateHeight: NSLayoutConstraint, _ dateLabel: UILabel) {
        let dateFull = PublicFunction().dateLongToString(dateInMillis: Double(exactly: listChat[index].createdAt!)!, pattern: "dd MMMM yyyy")
        
        if index > 0 {
            let dateBeforeFull = PublicFunction().dateLongToString(dateInMillis: Double(exactly: listChat[index - 1].createdAt!)!, pattern: "dd MMMM yyyy")
            let dateMonth = PublicFunction().dateLongToString(dateInMillis: Double(exactly: listChat[index].createdAt!)!, pattern: "dd MMMM")
            let year = PublicFunction().dateLongToString(dateInMillis: Double(exactly: listChat[index].createdAt!)!, pattern: "yyyy")
            let yearBefore = PublicFunction().dateLongToString(dateInMillis: Double(exactly: listChat[index - 1].createdAt!)!, pattern: "yyyy")
            
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
            let date = PublicFunction().dateLongToString(dateInMillis: Double(exactly: listChat[index].createdAt!)!, pattern: "dd MMMM yyyy")
            let dateBefore = PublicFunction().dateLongToString(dateInMillis: Double(exactly: listChat[index - 1].createdAt!)!, pattern: "dd MMMM yyyy")
            
            if date == dateBefore {
                return CGSize(width: UIScreen.main.bounds.width, height: withoutDateSize)
            } else {
                return CGSize(width: UIScreen.main.bounds.width, height: originalSize)
            }
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: originalSize)
        }
    }
    
    private func sendMessage() {
        thisChannel?.sendUserMessage(inputChat.text?.trim(), completionHandler: { (message, error) in
            if let err = error {
                print("error sending message \(err.localizedDescription)")
                return
            }
            
            //update the ui
            self.inputChat.text = ""
            
            self.listChat.append(ChatModel((message?.messageId)!, (message?.message)!, (message?.createdAt)!, (message?.sender?.userId)!, .text))
            
            self.chatCollectionView.insertItems(at: [IndexPath(item: self.listChat.count - 1, section: 0)])
            
            self.chatCollectionView.scrollToItem(at: IndexPath(item: self.listChat.count - 1, section: 0), at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
        })
    }
}

//MARK: Handle Gesture
extension ChatController {
    @objc func iconAddImageClick() {
        ImagePickerManager().pickImage(self) { (image, url) in
            let imagePreviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewController") as! ImagePreviewController
            imagePreviewController.imageUrl = url
            imagePreviewController.imagePicked = image
            imagePreviewController.delegate = self
            self.present(imagePreviewController, animated: true)
        }
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

//MARK: Protocol
extension ChatController: ImagePreviewControllerProtocol{
    func reloadData() {
        if let channel = thisChannel {
            SBDMain.add(self as SBDChannelDelegate, identifier: (channel.channelUrl))
            
            self.populateData(channel)
        }
    }
}

//MARK: Collectionview
extension ChatController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listChat.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if listChat[indexPath.row].typeMessage == .text && listChat[indexPath.row].sender == SBDMain.getCurrentUser()?.userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatCell", for: indexPath) as! MyChatCell
            cell.dataMessage = listChat[indexPath.row]
            self.checkDateCell(cell.contentMainHeight, indexPath.row, cell.dateHeight, cell.date)
            return cell
        } else if listChat[indexPath.row].typeMessage == .text && listChat[indexPath.row].sender != SBDMain.getCurrentUser()?.userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentChatCell", for: indexPath) as! OpponentChatCell
            cell.dataMessage = listChat[indexPath.row]
            self.checkDateCell(cell.contentMainHeight, indexPath.row, cell.dateHeight, cell.date)
            return cell
        } else if listChat[indexPath.row].typeMessage == .image && listChat[indexPath.row].sender == SBDMain.getCurrentUser()?.userId {
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
        if listChat[indexPath.row].typeMessage == .text && listChat[indexPath.row].sender == SBDMain.getCurrentUser()?.userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatCell", for: indexPath) as! MyChatCell
            return self.checkDateCellSize(cell.message, cell.date, indexPath.row)
        } else if listChat[indexPath.row].typeMessage == .text && listChat[indexPath.row].sender != SBDMain.getCurrentUser()?.userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentChatCell", for: indexPath) as! OpponentChatCell
            return self.checkDateCellSize(cell.message, cell.date, indexPath.row)
        } else if listChat[indexPath.row].typeMessage == .image && listChat[indexPath.row].sender == SBDMain.getCurrentUser()?.userId {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatImageCell", for: indexPath) as! MyChatImageCell
            return CGSize(width: UIScreen.main.bounds.width, height: cell.date.frame.height + 30 + cell.image.frame.height + 9)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentChatImageCell", for: indexPath) as! OpponentChatImageCell
            return CGSize(width: UIScreen.main.bounds.width, height: cell.date.frame.height + 30 + cell.image.frame.height + 9)
        }
    }
}

//MARK: Sendbird Delegate
extension ChatController: SBDChannelDelegate {
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender.channelUrl == thisChannel?.channelUrl {
            if message is SBDUserMessage {
                guard let userMessage = message as? SBDUserMessage else {return}
                self.listChat.append(ChatModel(userMessage.messageId, userMessage.message!, userMessage.createdAt, (userMessage.sender?.userId)!, .text))
                self.chatCollectionView.insertItems(at: [IndexPath(item: self.listChat.count - 1, section: 0)])
                self.chatCollectionView.scrollToItem(at: IndexPath(item: self.listChat.count - 1, section: 0), at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
            }
            else if message is SBDFileMessage {
                guard let fileMessage = message as? SBDFileMessage else {return}
                self.listChat.append(ChatModel(fileMessage.messageId, fileMessage.url, fileMessage.createdAt, (fileMessage.sender?.userId)!, .image))
                self.chatCollectionView.insertItems(at: [IndexPath(item: self.listChat.count - 1, section: 0)])
                self.chatCollectionView.scrollToItem(at: IndexPath(item: self.listChat.count - 1, section: 0), at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
            }
            else if message is SBDAdminMessage {
                print("its admin message")
            }
        }
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        if sender.channelUrl == self.thisChannel!.channelUrl {
            let typingMembers = sender.getTypingMembers()
            
            if (typingMembers?.count)! > 1 {
                opponentStatus.text = "Typing..."
            } else if typingMembers?.count == 1 && typingMembers![0].userId != SBDMain.getCurrentUser()?.userId {
                opponentStatus.text = "Typing..."
            } else {
                self.checkOpponentStatus { (isOnline, lastSeen, name) in
                    if isOnline {
                        self.opponentStatus.text = "Online"
                    } else {
                        self.opponentStatus.text = "Last seen at \(lastSeen)"
                    }
                }
            }
        }
    }
}
