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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    //indicator dot
    @IBOutlet weak var textGajaman: UIButton!
    @IBOutlet weak var dot1: UIView!
    @IBOutlet weak var dot2: UIView!
    @IBOutlet weak var dot3: UIView!
    @IBOutlet weak var dot4: UIView!
    @IBOutlet weak var dot5: UIView!
    @IBOutlet weak var dot6: UIView!
    @IBOutlet weak var dot6Height: NSLayoutConstraint!
    @IBOutlet weak var dot6Width: NSLayoutConstraint!
    @IBOutlet weak var dot5Height: NSLayoutConstraint!
    @IBOutlet weak var dot5Width: NSLayoutConstraint!
    @IBOutlet weak var dot4Height: NSLayoutConstraint!
    @IBOutlet weak var dot4Width: NSLayoutConstraint!
    @IBOutlet weak var dot3Height: NSLayoutConstraint!
    @IBOutlet weak var dot3Width: NSLayoutConstraint!
    @IBOutlet weak var dot2Height: NSLayoutConstraint!
    @IBOutlet weak var dot2Width: NSLayoutConstraint!
    @IBOutlet weak var dot1Width: NSLayoutConstraint!
    @IBOutlet weak var dot1Height: NSLayoutConstraint!
    
    //MARK: Props
    private var welcomeList = [WelcomeModel]()
    private var currentPage = 0
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: StaticVar.login) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toHomeController", sender: self)
            }
        } else if UserDefaults.standard.bool(forKey: StaticVar.hasAccount) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLoginRegisterController", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)

        customView()
        
        initCollectionView()
        
        generateData()
        
        handleGestureListener()
    }
    
    private func customView() {
        focusIndicator(dot1, dot1Height, dot1Width)
        dot2.layer.cornerRadius = dot2.frame.height / 2
        dot3.layer.cornerRadius = dot3.frame.height / 2
        dot4.layer.cornerRadius = dot4.frame.height / 2
        dot5.layer.cornerRadius = dot5.frame.height / 2
        dot6.layer.cornerRadius = dot6.frame.height / 2
    }
    
    private func handleGestureListener() {
        nextButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextButtonClick(sender:))))
        skipButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skipButtonClick(sender:))))
    }
    
    private func generateData() {
        welcomeList.append(WelcomeModel(imageHeader: "welcome_screen_1"))
        welcomeList.append(WelcomeModel(imageHeader: "welcome_screen_2"))
        welcomeList.append(WelcomeModel(imageHeader: "welcome_screen_3"))
        welcomeList.append(WelcomeModel(imageHeader: "welcome_screen_4"))
        welcomeList.append(WelcomeModel(imageHeader: "welcome_screen_5"))
        welcomeList.append(WelcomeModel(imageHeader: "welcome_screen_6"))
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
        highlightIndicator(self.currentPage)
        changeButtonDynamically(self.currentPage)
    }
    
    func highlightIndicator(_ page: Int) {
        switch page {
        case 0:
            focusIndicator(dot1, dot1Height, dot1Width)
            unfocusIndicator(dot2, dot2Height, dot2Width)
            unfocusIndicator(dot3, dot3Height, dot3Width)
            unfocusIndicator(dot4, dot4Height, dot4Width)
            unfocusIndicator(dot5, dot5Height, dot5Width)
            unfocusIndicator(dot6, dot6Height, dot6Width)
        case 1:
            unfocusIndicator(dot1, dot1Height, dot1Width)
            focusIndicator(dot2, dot2Height, dot2Width)
            unfocusIndicator(dot3, dot3Height, dot3Width)
            unfocusIndicator(dot4, dot4Height, dot4Width)
            unfocusIndicator(dot5, dot5Height, dot5Width)
            unfocusIndicator(dot6, dot6Height, dot6Width)
        case 2:
            unfocusIndicator(dot1, dot1Height, dot1Width)
            unfocusIndicator(dot2, dot2Height, dot2Width)
            focusIndicator(dot3, dot3Height, dot3Width)
            unfocusIndicator(dot4, dot4Height, dot4Width)
            unfocusIndicator(dot5, dot5Height, dot5Width)
            unfocusIndicator(dot6, dot6Height, dot6Width)
        case 3:
            unfocusIndicator(dot1, dot1Height, dot1Width)
            unfocusIndicator(dot2, dot2Height, dot2Width)
            unfocusIndicator(dot3, dot3Height, dot3Width)
            focusIndicator(dot4, dot4Height, dot4Width)
            unfocusIndicator(dot5, dot5Height, dot5Width)
            unfocusIndicator(dot6, dot6Height, dot6Width)
        case 4:
            unfocusIndicator(dot1, dot1Height, dot1Width)
            unfocusIndicator(dot2, dot2Height, dot2Width)
            unfocusIndicator(dot3, dot3Height, dot3Width)
            unfocusIndicator(dot4, dot4Height, dot4Width)
            focusIndicator(dot5, dot5Height, dot5Width)
            unfocusIndicator(dot6, dot6Height, dot6Width)
        default:
            unfocusIndicator(dot1, dot1Height, dot1Width)
            unfocusIndicator(dot2, dot2Height, dot2Width)
            unfocusIndicator(dot3, dot3Height, dot3Width)
            unfocusIndicator(dot4, dot4Height, dot4Width)
            unfocusIndicator(dot5, dot5Height, dot5Width)
            focusIndicator(dot6, dot6Height, dot6Width)
        }
    }
    
    func focusIndicator(_ view: UIView, _ height: NSLayoutConstraint, _ width: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.2) {
            height.constant = 12
            width.constant = 12
            view.layer.cornerRadius = 12 / 2
            self.view.layoutIfNeeded()
        }
    }
    
    func unfocusIndicator(_ view: UIView, _ height: NSLayoutConstraint, _ width: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.2) {
            height.constant = 8
            width.constant = 8
            view.layer.cornerRadius = 8 / 2
            self.view.layoutIfNeeded()
        }
    }
    
    func changeButtonDynamically(_ page: Int) {
        if page == 5 {
            self.nextButton.setTitle("Done", for: .normal)
            self.skipButton.isHidden = true
            self.textGajaman.setTitle("", for: .normal)
        } else {
            if page == 4 {
                self.textGajaman.setTitle("#GAJAMANPAKEKARCISPARKIR", for: .normal)
            } else {
                self.textGajaman.setTitle("", for: .normal)
            }
            
            self.nextButton.setTitle("Next", for: .normal)
            self.skipButton.isHidden = false
        }
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
        return cell
    }
}

//MARK: Welcome cell handle gesture listener
extension WelcomeController {
    @objc func skipButtonClick(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toLoginRegisterController", sender: self)
    }
    
    @objc func nextButtonClick(sender: UITapGestureRecognizer) {
        if let indexpath = welcomeCollectionVIew.indexPathForItem(at: sender.location(in: welcomeCollectionVIew)){
            switch indexpath.item {
            case 5:
                self.performSegue(withIdentifier: "toLoginRegisterController", sender: self)
            default:
                currentPage += 1
                highlightIndicator(currentPage)
                welcomeCollectionVIew.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: .centeredHorizontally, animated: true)
                
                self.changeButtonDynamically(currentPage)
            }
        }
    }
}
