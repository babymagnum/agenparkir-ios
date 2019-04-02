//
//  DirectionController.swift
//  Agen Parkir
//
//  Created by Arief Zainuri on 13/03/19.
//  Copyright © 2019 Mika. All rights reserved.
//

import UIKit
import MapKit

class DirectionController: UIViewController, MKMapViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconDirection: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var iconBack: UIImageView!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var viewTimeWidth: NSLayoutConstraint!
    
    //MARK: Props
    var dataDirection: (latitude: String, longitude: String, building_name: String, timer: Int, booking_status_id: Int)?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customView()
        
        initMap()
        
        handleGesture()
        
        loadDefaultData()
    }
    
    private func loadDefaultData() {
        if let data = dataDirection {
            switch data.booking_status_id {
            case 1:
                self.startTimer()
            default:
                self.viewTime.isHidden = true
            }
        }
    }
    
    private func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.dataDirection?.timer -= 1
            
            self.timeLeft.text = "\((self.dataDirection?.timer)! / 60):\((self.dataDirection?.timer)! % 60)"
            
            UIView.animate(withDuration: 0.15, animations: {
                self.viewTimeWidth.constant = 10 + 40 + 10 + self.timeLeft.frame.width + 10
                self.view.layoutIfNeeded()
            })
            
            if (self.dataDirection?.timer)! <= 0 {
                timer.invalidate()
                self.timeLeft.text = "00:00"
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
    }
    
    private func handleGesture() {
        viewBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewBackClick)))
        iconDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconDirectionClick)))
    }
    
    private func initMap(){
        // 1.
        mapView.delegate = self

        guard let safeLatLnt = dataDirection else { return }
        
        // 2.
        let sourceLocation = CLLocationCoordinate2D(latitude: Double(UserDefaults.standard.string(forKey: StaticVar.latitude)!)!, longitude: Double(UserDefaults.standard.string(forKey: StaticVar.longitude)!)!)
        let destinationLocation = CLLocationCoordinate2D(latitude: Double(safeLatLnt.latitude)!, longitude: Double(safeLatLnt.longitude)!)

        // 3.
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)

        // 4.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        // 5.
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "My Location"

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }


        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = safeLatLnt.building_name

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        // 6.
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

        // 7.
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile

        // Calculate the direction
        let directions = MKDirections(request: directionRequest)

        // 8.
        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }

                return
            }

            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    private func customView() {
        viewTimeWidth.constant = 10 + 40 + 10 + timeLeft.frame.width + 10
        viewTime.layer.cornerRadius = viewTime.frame.height / 2
        PublicFunction().changeTintColor(imageView: iconBack, hexCode: 0x0D47A1, alpha: 1.0)
        viewBack.layer.cornerRadius = 10
        viewBack.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        iconDirection.setImage(UIImage(named: "direction")?.tinted(with: UIColor(rgb: 0x2B3990)), for: .normal)
        iconDirection.clipsToBounds = true
        iconDirection.layer.cornerRadius = 5
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(rgb: 0x0984e3)
        renderer.lineWidth = 2.0
        
        return renderer
    }
}

extension DirectionController{
    @objc func iconDirectionClick() {
        
        guard let safeLatLnt = dataDirection else { return }
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(UserDefaults.standard.string(forKey: StaticVar.latitude)!)!, longitude: Double(UserDefaults.standard.string(forKey: StaticVar.longitude)!)!)))
        source.name = "My Location"
        
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(safeLatLnt.latitude)!, longitude: Double(safeLatLnt.longitude)!)))
        destination.name = dataDirection?.building_name
        
        let alert = UIAlertController(title: "Open Direction", message: "You want to open apple maps to get driving direction?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func viewBackClick() {
        navigationController?.popViewController(animated: true)
    }
}
