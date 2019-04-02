//
//  WelcomeController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 25/02/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class WelcomeController: UIViewController, UICollectionViewDelegate {

    //MARK: Outlet
    @IBOutlet weak var welcomeCollectionVIew: UICollectionView!
    
    //MARK: Props
    private var welcomeList = [WelcomeModel]()
    private var currentPage = 0
    private var tapClicked = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: StaticVar.login) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toHomeController", sender: self)
            }
        } else if UserDefaults.standard.bool(forKey: StaticVar.hasAccount) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.performSegue(withIdentifier: "toLoginRegisterController", sender: self)
            }
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)

        initCollectionView()
        
        generateData()
        
        handleGestureListener()
    }
    
    private func handleGestureListener() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick)))
    }
    
    private func generateData() {
        welcomeList.append(WelcomeModel(imageHeader: "Screen Shot 2019-02-25 at 09.34.30", title: "Header 1", message: "Message 1", selectedPage: 0))
        welcomeList.append(WelcomeModel(imageHeader: "Screen Shot 2019-02-25 at 09.34.30", title: "Header 2", message: "Message 2", selectedPage: 0))
        welcomeList.append(WelcomeModel(imageHeader: "Screen Shot 2019-02-25 at 09.34.30", title: "Header 3", message: "Message 3", selectedPage: 0))
        welcomeList.append(WelcomeModel(imageHeader: "Screen Shot 2019-02-25 at 09.34.30", title: "Header 4", message: "Message 4", selectedPage: 0))
        welcomeList.append(WelcomeModel(imageHeader: "Screen Shot 2019-02-25 at 09.34.30", title: "Header 5", message: "Message 5", selectedPage: 0))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.welcomeCollectionVIew.reloadData()
        }
    }

    private func initCollectionView() {
        welcomeCollectionVIew.delegate = self
        welcomeCollectionVIew.dataSource = self
        welcomeCollectionVIew.isPagingEnabled = true
        welcomeCollectionVIew.showsHorizontalScrollIndicator = false
        
        let layout = welcomeCollectionVIew.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
}

//MARK: Handle welcome collectionview page change
extension WelcomeController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        self.currentPage = currentPage
        welcomeList[currentPage].selectedPage = currentPage
        welcomeCollectionVIew.reloadData()
    }
}

//MARK: Welcome collection view data source
extension WelcomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return welcomeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeCell", for: indexPath) as! WelcomeCell
        cell.welcomeModel = welcomeList[indexPath.item]
        cell.skipButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skipButtonClick(sender:))))
        cell.nextButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextButtonClick(sender:))))
        return cell
    }
}

//MARK: Welcome cell handle gesture listener
extension WelcomeController {
    @objc func viewClick() {
        print("tap \(tapClicked)")
        tapClicked += 1
        
        if tapClicked == 15 {
            self.tapClicked = 0
            UserDefaults.standard.set("Dev", forKey: StaticVar.applicationState)
            let alert = UIAlertController(title: "Developing State", message: "You're in developing state. All API will hit developing api url", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Understand", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc func skipButtonClick(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toLoginRegisterController", sender: self)
    }
    
    @objc func nextButtonClick(sender: UITapGestureRecognizer) {
        if let indexpath = welcomeCollectionVIew.indexPathForItem(at: sender.location(in: welcomeCollectionVIew)){
            switch indexpath.item {
            case 4:
                self.performSegue(withIdentifier: "toLoginRegisterController", sender: self)
            default:
                currentPage += 1
                welcomeList[currentPage].selectedPage = currentPage
                welcomeCollectionVIew.reloadData()
                welcomeCollectionVIew.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}
