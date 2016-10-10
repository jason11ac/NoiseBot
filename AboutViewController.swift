//
//  AboutViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/30/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var aboutLabel: UILabel!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About"

        aboutLabel.text = "NoiseBot\nis an app by\nAmbient Bots Inc\n\nVersion 1.2"
        aboutLabel.textAlignment = .center
        aboutLabel.numberOfLines = 5
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
