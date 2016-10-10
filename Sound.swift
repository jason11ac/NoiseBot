//
//  Sound.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/7/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//


import UIKit
import CloudKit

class Sound: NSObject {
    
    // MARK: CloudKit Sound Properties
    ////////////////////////////
    var address: String!
    var audio: URL!
    var city: String!
    var comments: String!
    var country: String!
    var date: String!
    var lat: Double!
    var long: Double!
    var recordID: CKRecordID!
    var state: String!
    var type: String!
    var zip: String!
    ////////////////////////////
}
