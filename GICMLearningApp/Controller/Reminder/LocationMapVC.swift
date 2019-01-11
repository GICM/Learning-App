//
//  ViewController.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/23/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import UserNotificationsUI
import GoogleMaps

var circularIdentifier = ""
let regionRadius = 100.0
var arrayCircularRegion:[CLCircularRegion] = []
class LocationMapVC: UIViewController, MKMapViewDelegate ,UIGestureRecognizerDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var monitoredRegions: Dictionary<String, Date> = [:]
    var circularRegion = CLCircularRegion()
    var annotation = MKPointAnnotation()
    var circle = MKCircle()
    
    let titleAnnotation = "Pick the Location"
    var firstTimeLoaded = true
    var locationManager:CLLocationManager!
    var strLat:String?
    var strLong:String?
    var isEdit = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEdit {
            let lat = Double(strLat!)
            let long = Double(strLong!)
            let cord = CLLocationCoordinate2D.init(latitude: lat!, longitude: long!)
            setupData(coordinate: cord)
            firstTimeLoaded = false
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.headingFilter = 5
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
        // setup mapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        setMapview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied {
            showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
        }
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let pwr = Double(20 - mapView.zoomLevel())
        let zoomFactor = pow(2,pwr)
        print("...REGION DID CHANGE: ZOOM FACTOR \(zoomFactor) --  \(pwr)")
        if pwr > 1.0 {
            mapView.remove(circle)
            circle = MKCircle(center: annotation.coordinate, radius: zoomFactor)
            mapView.add(circle)
        }
    }
    
    func setMapview(){
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            let touchLocation = gestureReconizer.location(in: self.mapView)
            
            let locationCoordinate = self.mapView.convert(touchLocation,toCoordinateFrom: self.mapView)
            self.annotation.coordinate = locationCoordinate
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            
            mapView.remove(circle)
            circle = MKCircle(center: locationCoordinate, radius: regionRadius)
            mapView.add(circle)
            return
        }
        if gestureReconizer.state != UIGestureRecognizerState.began {
            return
        }
    }
    
    func setupData(coordinate:CLLocationCoordinate2D) {
        // check if can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            annotation.coordinate = coordinate;
            annotation.title = "\(titleAnnotation)";
            mapView.addAnnotation(annotation)
            mapView.remove(circle)
            circle = MKCircle(center: annotation.coordinate, radius: regionRadius)
            mapView.add(circle)
        }
        else {
            print("System can't track regions")
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func selectThisLocation(_ sender: Any) {
        // reverseGeocodeCoordinate()
        reverseGeocodeCoordinateGoogle(annotation.coordinate)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations = \(String(describing: locations.first?.coordinate.latitude)) \(String(describing: locations.first?.coordinate.longitude))")
        if firstTimeLoaded {
            firstTimeLoaded = false
            if let location = locations.first {
                setupData(coordinate: location.coordinate)
            }
        }
    }
    // MARK: - Helpers
    
    func showAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    private func reverseGeocodeCoordinateGoogle(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                Utilities.displayFailureAlertWithMessage(title: "Attention!", message: "Please press the long tap in the map to get selected location", controller: self)
                return
            }
            print(lines)
            let message = lines.joined(separator: "\n")
            Utilities.showAlertOkandCancelWithDismiss(title: "Use This Location?", okTitile: "Select", cancelTitle: "Change Location", message: message, controller: self, alertDismissed: { (select) in
                if select {
                    //Go to Next VC with address and 2D location
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller is DetailedReminderVC
                        {
                            if let vc = controller as? DetailedReminderVC {
                                vc.strLatitude = String(coordinate.latitude)
                                vc.strLongitude = String(coordinate.longitude)
                                let address = lines.joined(separator: ",")
                                vc.btnSelectLocation.setTitle(address, for: .normal)
                                vc.addressLocation = address
                                vc.locaionCoordinates = coordinate
                                vc.circularRegion = self.circularRegion
                                let _ =  self.navigationController?.popToViewController( vc as UIViewController, animated: true)
                                break
                            }
                            
                        }
                    }
                } else {
                    
                }
            })
        }
    }
}
