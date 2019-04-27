//
//  ImagePreviewController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 01/04/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import SendBirdSDK
import SVProgressHUD

protocol ImagePreviewControllerProtocol {
    func reloadData()
}

class ImagePreviewController: BaseViewController, UICollectionViewDelegate {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var listImageUrl = [UIImage]()
    var imageUrl: URL?
    var imagePicked: UIImage?
    var channelUrl: String?
    var delegate: ImagePreviewControllerProtocol?
    var thisChannel: SBDGroupChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCollectionView()
        
        joinChannelWithUrl()
        
        loadImage()
        
        handleGesture()
    }
    
    private func initCollectionView() {
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.isPagingEnabled = true
        
        let layout = imageCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: imageCollectionView.frame.height)
    }
    
    private func joinChannelWithUrl() {
        SBDGroupChannel.createChannel(withUserIds: ["user1"], isDistinct: true) { (groupChannel, error) in
            if let err = error {
                PublicFunction.instance.showUnderstandDialog(self, "Error Join Channel", err.localizedDescription, "Understand")
                return
            }
            
            self.thisChannel = groupChannel
        }
    }
    
    private func handleGesture() {
        sendButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendButtonClick)))
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelButtonClick)))
    }
    
    private func loadImage() {
        listImageUrl.append(imagePicked!)
        imageCollectionView.reloadData()
    }
}

extension ImagePreviewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listImageUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePreviewCell", for: indexPath) as! ImagePreviewCell
        cell.dataImage = listImageUrl[indexPath.row]
        return cell
    }
}

extension ImagePreviewController {
    @objc func sendButtonClick() {
        SVProgressHUD.show()
        let data = imagePicked?.jpegData(compressionQuality: 0.5)
        
        thisChannel?.sendFileMessage(withBinaryData: data!, filename: (imageUrl?.lastPathComponent)!, type: (imageUrl?.lastPathComponent.components(separatedBy: ".")[1])!, size: UInt(CGFloat((data?.count)!)), data: "image", completionHandler: { (fileMessage, error) in
            
            if let err = error {
                print("failed to send image message \(err.localizedDescription)")
                return
            }
            
            SVProgressHUD.dismiss()
            
            print("success send file message \(fileMessage?.url)")
            
            self.dismiss(animated: true) {
                self.delegate?.reloadData()
            }
        })
    }
    
    @objc func cancelButtonClick() {
        dismiss(animated: true, completion: nil)
    }
}

class ImagePreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    var dataImage: UIImage? {
        didSet{
            if let data = dataImage {
                image.image = data
            }
        }
    }
}
