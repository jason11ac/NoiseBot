//
//  HelpViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/30/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var helpLabel: UILabel!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Help"
        
        helpLabel.text = "Tutorial\ncoming soon!"
        helpLabel.textAlignment = .center
        helpLabel.numberOfLines = 2
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    

}
