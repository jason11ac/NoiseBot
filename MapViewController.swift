//
//  MapViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/26/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


//MARK: Global Properties
///////////////////////////////
//For location of listener
var lat: Double!
var long: Double!
///////////////////////////////



class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Set Location"
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        self.mapView.showsUserLocation = true
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
        
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func addSound() {
        
        let vc = RecordNoiseViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Location Manager Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied {
            //Denied access
            let ac = UIAlertController(title: "Location Failed", message: "NoiseBot needs permission to access your location while the app is in use. Please allow this in settings to continue.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            navigationItem.rightBarButtonItem = nil
        } else if status == .restricted {
            //Denied access
            let ac = UIAlertController(title: "Location Failed", message: "NoiseBot needs permission to access your location while the app is in use. Please allow this in settings to continue.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            navigationItem.rightBarButtonItem = nil
        } else {
            //Allowed access
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addSound))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        //Zoom settings
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        
        lat = location!.coordinate.latitude
        long = location!.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
