//
//  OngoingCell.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 12/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit

class OngoingCell: UICollectionViewCell {
    //MARK: Outlet
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewBarcode: UIView!
    @IBOutlet weak var viewMaps: UIView!
    @IBOutlet weak var viewMessage: UIView!
    
    var timeLeftMotor = 600 //seconds
    var timeLeftCars = 900 //seconds
    var timerLast = 0
    
    var parkingTimer: Timer?
    
    override func awakeFromNib() {
        contentMain.clipsToBounds = true
        contentMain.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.7
    }
    
    var ongoingData: OngoingModel? {
        didSet{
            if let data = ongoingData {
                let longDate = PublicFunction.instance.dateStringToInt(stringDate: data.booking_start_time!, pattern: "yyyy-MM-dd kk:mm:ss")
                venueName.text = data.building_name
                orderDate.text = PublicFunction.instance.dateLongToString(dateInMillis: longDate, pattern: "dd MMMM yyyy, kk:mm a")
                
                if data.vehicle_type == 0 {
                    timerLast = UserDefaults.standard.integer(forKey: StaticVar.last_timer) - Calendar.current.dateComponents([.second], from: PublicFunction.instance.getDate(stringDate: UserDefaults.standard.string(forKey: StaticVar.time_timer_removed)!, pattern: "yyyy-MM-dd kk:mm:ss")!, to: PublicFunction.instance.getDate(stringDate: PublicFunction.instance.getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), pattern: "yyyy-MM-dd kk:mm:ss")!).second!
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.startTimer(data)
                }
            }
        }
    }
    
    private func startTimer(_ data: OngoingModel){
        switch data.vehicle_type {
        case 1: //motor
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                self.timeLeftMotor -= 1
                
                UserDefaults.standard.set(self.timeLeftMotor, forKey: StaticVar.last_timer)
                
                print("Sisa waktu \(self.timeLeftMotor)")
                
                self.timer.text = "\(self.timeLeftMotor / 60):\(self.timeLeftMotor % 60)"

                if data.removeTimer! {
                    print("timer motor removed because in background")
                    UserDefaults.standard.set(PublicFunction.instance.getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), forKey: StaticVar.time_timer_removed)
                    timer.invalidate()
                } else if self.timeLeftMotor == 0 {
                    timer.invalidate()
                }
            }
        case 2: //mobil
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                self.timeLeftCars -= 1
                
                UserDefaults.standard.set(self.timeLeftCars, forKey: StaticVar.last_timer)
                
                print("Sisa waktu \(self.timeLeftCars)")
                
                self.timer.text = "\(self.timeLeftCars / 60):\(self.timeLeftCars % 60 > 10 ? self.timeLeftCars % 60 : Int("0\(self.timeLeftCars % 60)") ?? 1)"
                
                if data.removeTimer! {
                    print("timer cars removed because in background")
                    UserDefaults.standard.set(PublicFunction.instance.getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), forKey: StaticVar.time_timer_removed)
                    timer.invalidate()
                } else if self.timeLeftCars == 0 {
                    timer.invalidate()
                }
            }
        default:
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                self.timerLast -= 1
                
                UserDefaults.standard.set(self.timerLast, forKey: StaticVar.last_timer)
                
                print("Sisa waktu \(self.timerLast)")
                
                self.timer.text = "\(self.timerLast / 60):\(self.timerLast % 60 > 10 ? self.timerLast % 60 : Int("0\(self.timerLast % 60)") ?? 1)"
                
                if data.removeTimer! {
                    print("timer default removed because in background")
                    UserDefaults.standard.set(PublicFunction.instance.getCurrentDate(pattern: "yyyy-MM-dd kk:mm:ss"), forKey: StaticVar.time_timer_removed)
                    timer.invalidate()
                } else if self.timerLast == 0 {
                    timer.invalidate()
                }
            }
        }
    }
}
