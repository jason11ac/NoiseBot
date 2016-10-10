//
//  AddCommentsViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/7/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation


//MARK: Global Properties
///////////////////////////////
var soundRecord: CKRecord!
///////////////////////////////



class AddCommentsViewController: UIViewController, UITextViewDelegate {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    var type: String!
    var comments: UITextView!
    let placeholder = "Additional comments"
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func loadView() {
        super.loadView()
        
        comments = UITextView()
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.delegate = self
        comments.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        view.addSubview(comments)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[comments]|", options: .alignAllCenterX, metrics: nil, views: ["comments": comments]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[comments]|", options: .alignAllCenterX, metrics: nil, views: ["comments": comments]))
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(submitTapped))
        comments.text = placeholder
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Set Location Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    //Set location of record
    func setLocation(_ record: CKRecord) {
        
        record["lat"] = lat as CKRecordValue?
        record["long"] = long as CKRecordValue?
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: long)
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            
            let placeArray = placemarks as [CLPlacemark]!
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            // Location name
            if let locationName = placeMark.addressDictionary?["Name"] as? String {
                record["address"] = locationName as CKRecordValue?
            }
            // City
            if let city = placeMark.addressDictionary?["City"] as? String {
                record["city"] = city as CKRecordValue?
            }
            // State
            if let state = placeMark.addressDictionary?["State"] as? String {
                record["state"] = state as CKRecordValue?
            }
            // Zip code
            if let zip = placeMark.addressDictionary?["ZIP"] as? String {
                record["zip"] = zip as CKRecordValue?
            }
            // Country
            if let country = placeMark.addressDictionary?["Country"] as? String {
                record["country"] = country as CKRecordValue?
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    

    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func submitTapped() {
        
        soundRecord = CKRecord(recordType: "Sound")
        
        let vc = SubmitViewController()
        vc.type = type
        
        if comments.text == placeholder {
            vc.comments = ""
        } else {
            vc.comments = comments.text
        }
        
        //Set location here so it happens before submission
        setLocation(soundRecord)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: TextField Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
