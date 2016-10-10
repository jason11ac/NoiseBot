//
//  ShowSoundLocationViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/27/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ShowSoundLocationViewController: UIViewController, MKMapViewDelegate {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var mapView: MKMapView!
    
    var sound: Sound!
    var lat: Double!
    var long: Double!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Noise Location"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen", style: .plain, target: self, action: #selector(listen))
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        //Zoom settings
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.mapView.setRegion(region, animated: true)
        
        //Drop annotation/pin at center location
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.mapView.addAnnotation(annotation)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func listen() {
        let vc = ResultsViewController()
        vc.sound = sound
        vc.downloadTapped()
        navigationController?.pushViewController(vc, animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
