//
//  HomeScreenViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/29/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {

    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var setupButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    static var dirty: Bool = true
    
    let colorAnimationSetup = CABasicAnimation(keyPath: "backgroundColor")
    let colorAnimationMonitor = CABasicAnimation(keyPath: "backgroundColor")
    let colorAnimationView = CABasicAnimation(keyPath: "backgroundColor")
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        
        setupButton.addTarget(self, action: #selector(setupTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        
        setupButton.titleLabel?.numberOfLines = 2
        startButton.titleLabel?.numberOfLines = 2
        viewButton.titleLabel?.numberOfLines = 2
        viewButton.titleLabel?.textAlignment = .center
        
        submit = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(helpTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(aboutTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        deleteLastRecordingOffApp()
        
        //Setup and Start Button Colors
        if HomeScreenViewController.dirty {
            
            colorAnimationSetup.fromValue = UIColor.white.cgColor
            colorAnimationSetup.toValue = UIColor(red: 249/255, green: 255/255, blue: 18/255, alpha: 1.0).cgColor
            colorAnimationSetup.duration = 1
            colorAnimationSetup.autoreverses = true
            colorAnimationSetup.repeatCount = Float.infinity
            colorAnimationSetup.isRemovedOnCompletion = false
            setupButton.layer.add(colorAnimationSetup, forKey: "ColorPulse")
            
            startButton.backgroundColor = UIColor(red: 255/255, green: 2/255, blue: 15/255, alpha: 0.2)
        } else {
            
            //Setup Button
            setupButton.layer.removeAllAnimations()
            setupButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 1/255, alpha: 0.2)
            
            //Start Button
            colorAnimationMonitor.fromValue = UIColor.white.cgColor
            colorAnimationMonitor.toValue = UIColor(red: 255/255, green: 2/255, blue: 15/255, alpha: 0.7).cgColor
            colorAnimationMonitor.duration = 1
            colorAnimationMonitor.autoreverses = true
            colorAnimationMonitor.repeatCount = Float.infinity
            colorAnimationMonitor.isRemovedOnCompletion = false
            startButton.layer.add(colorAnimationMonitor, forKey: "ColorPulse")
        }
        
        if PublicRecordViewController.dirty {
            
            colorAnimationView.fromValue = UIColor.white.cgColor
            colorAnimationView.toValue = UIColor(red: 0/255, green: 166/255, blue: 1/255, alpha: 0.5).cgColor
            colorAnimationView.duration = 1
            colorAnimationView.autoreverses = true
            colorAnimationView.repeatCount = Float.infinity
            colorAnimationView.isRemovedOnCompletion = false
            viewButton.layer.add(colorAnimationView, forKey: "ColorPulse")
            
        } else {
            
            viewButton.layer.removeAllAnimations()
            viewButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 1/255, alpha: 0.2)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
   
    
    
    
    
    
    
    
    

    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func setupTapped() {
        
        //Set parameters
        let vc = ViewPicker()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func startTapped() {
        
        startButton.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 1/255, alpha: 0.2)
        
        //Start monitoring process
        let vc = MapViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func viewTapped() {
        
        //Show public record
        PublicRecordViewController.dirty = false
        let vc = PublicRecordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func aboutTapped() {
        
        //Show about page
        let vc = AboutViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpTapped() {
        
        //Show help page
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    //MARK: Deleting Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func deleteLastRecordingOffApp() {
        
        //Delete last recording as it is now saved/reported
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if paths.count > 0 {
            let rootPath = paths[0]
            let file = "Noise_File.m4a"
            let totalPath = NSString(format: "%@/%@", rootPath, file) as String
            if FileManager.default.fileExists(atPath: totalPath) {
                do {
                    try FileManager.default.removeItem(atPath: totalPath)
                    print("Success in deleting old noise file")
                } catch {
                    print("Error deleting old noise file")
                }
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
