//
//  DetailNewsController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 27/04/20.
//  Copyright © 2020 Mika. All rights reserved.
//

import UIKit
import WebKit

class DetailNewsController: UIViewController {

    @IBOutlet weak var imageBack: UIImageView!
    @IBOutlet weak var wkWebView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var newsId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        getNewsDetail()
        
        setupEvent()
    }
    
    private func setupEvent() {
        imageBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageBackClick)))
    }
    
    @objc func imageBackClick() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.changeStoryboardRoot()
    }
    
    private func getNewsDetail() {
        Networking().getDetailNews(newsId: newsId ?? "") { (detailNewsItem, error) in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                
                if let _error = error {
                    print(_error)
                    return
                }
                
                if let _detailsNewsItem = detailNewsItem {
                    self.wkWebView.loadHTMLString(_detailsNewsItem.content ?? "", baseURL: nil)
                }
            }
        }
    }

    private func setupView() {
        PublicFunction.instance.changeTintColor(imageView: imageBack, hexCode: 0x2B3990, alpha: 1.0)
    }
}
