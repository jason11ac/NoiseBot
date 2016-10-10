//
//  ReportViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/30/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportButton.titleLabel?.numberOfLines = 2
        reportButton.titleLabel?.textAlignment = .center
        homeButton.titleLabel?.numberOfLines = 2
        homeButton.titleLabel?.textAlignment = .center
        
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
        
        homeButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 1/255, alpha: 0.2)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = UIColor.white.cgColor
        colorAnimation.toValue = UIColor(red: 255/255, green: 2/255, blue: 15/255, alpha: 0.5).cgColor
        colorAnimation.duration = 1
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = FLT_MAX
        reportButton.layer.add(colorAnimation, forKey: "ColorPulse")
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func reportTapped() {
        
        let vc = ContactsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
   
    func homeTapped() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
