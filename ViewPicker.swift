//
//  ViewPicker.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/10/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit


//MARK: Global Properties
///////////////////////////////
//Global Default Keys
struct defaultGlobalKeys1 {
    static let key1 = "one"
    static let key2 = "two"
    static let keyEmail = "three"
    static let keyName = "four"
}
///////////////////////////////




class ViewPicker: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var myPicker: UIPickerView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    //For saving default data
    let defaults = UserDefaults.standard
    
    var dBlimitValue: Double = 60
    var intervalValue: Double = 20
    
    //DB
    let labeldB = UILabel()
    let dBlimit = UILabel()
    @IBOutlet weak var dBlimit1: UILabel!
    @IBOutlet weak var labeldB1: UILabel!
    
    
    //IT
    let labeliT = UILabel()
    let iTlimit = UILabel()
    @IBOutlet weak var iTlimit1: UILabel!
    @IBOutlet weak var labeliT1: UILabel!
    
    //Data for viewPicker
    let pickerData = [["Unset", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "110", "120"], ["Unset", "0.5", "1", "2", "5", "10", "20", "30", "60", "120", "300", "600", "1200"]]
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPicker.dataSource = self
        myPicker.delegate = self
        emailField.delegate = self
        nameField.delegate = self
        
        title = "Set Parameters"
        
        if let string1 = defaults.string(forKey: defaultGlobalKeys1.keyEmail) {
            emailField.textColor = UIColor.green
            emailField.text = string1
        }
        
        if let string2 = defaults.string(forKey: defaultGlobalKeys1.keyName) {
            nameField.textColor = UIColor.green
            nameField.text = string2
        }

        
        myPicker.selectRow(6, inComponent: 0, animated: true)
        myPicker.selectRow(6, inComponent: 1, animated: true)
        
        if let string1 = defaults.string(forKey: defaultGlobalKeys1.key1) {
            if (string1 != "0") {
                dBlimit1.textColor = UIColor.green
                dBlimit1.text = string1
            } else {
                dBlimit1.textColor = UIColor.green
                dBlimit1.text = "Unset"
            }
        } else {
            dBlimit1.textColor = UIColor.green
            dBlimit1.text = "Unset"
        }
        
        if let string2 = defaults.string(forKey: defaultGlobalKeys1.key2) {
            if (string2 != "0") {
                iTlimit1.textColor = UIColor.green
                iTlimit1.text = string2
            } else {
                iTlimit1.textColor = UIColor.green
                iTlimit1.text = "Unset"
            }
        } else {
            iTlimit1.textColor = UIColor.green
            iTlimit1.text = "Unset"
        }
        
        ///////////////////////
        //Decibel limit label//
        ///////////////////////
        labeldB1.backgroundColor = UIColor.white
        labeldB1.textColor = UIColor.black
        labeldB1.textAlignment = NSTextAlignment.center
        labeldB1.numberOfLines = 2
        labeldB1.text = "Decibel Limit (dB)"
        self.view.addSubview(labeldB1)

        //Show the limit picked
        dBlimit1.backgroundColor = UIColor.white
        dBlimit1.textAlignment = NSTextAlignment.center
        dBlimit1.numberOfLines = 1
        dBlimit1.font = UIFont.boldSystemFont(ofSize: 35)
        self.view.addSubview(dBlimit1)
        
        
        ///////////////////////
        //Time Interval label//
        ///////////////////////
        labeliT1.backgroundColor = UIColor.white
        labeliT1.textColor = UIColor.black
        labeliT1.textAlignment = NSTextAlignment.center
        labeliT1.numberOfLines = 2
        labeliT1.text = "Interval Time\n(sec)"
        self.view.addSubview(labeliT1)
        
        //Show the interval picked
        iTlimit1.backgroundColor = UIColor.white
        iTlimit1.textAlignment = NSTextAlignment.center
        iTlimit1.numberOfLines = 1
        iTlimit1.font = UIFont.boldSystemFont(ofSize: 35)
        self.view.addSubview(iTlimit1)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    

    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func saveTapped() {
        
        dBlimit1.textColor = UIColor.green
        iTlimit1.textColor = UIColor.green
        emailField.textColor = UIColor.green
        nameField.textColor = UIColor.green
        
        
        defaults.setValue(dBlimitValue, forKey: defaultGlobalKeys1.key1)
        defaults.setValue(intervalValue, forKey: defaultGlobalKeys1.key2)
        
        
        defaults.setValue(emailField.text!, forKey: defaultGlobalKeys1.keyEmail)
        defaults.setValue(nameField.text!, forKey: defaultGlobalKeys1.keyName)
        
        print(dBlimitValue)
        print(intervalValue)
        print(emailField.text!)
        print(nameField.text!)
        
        emailField.resignFirstResponder()
        nameField.resignFirstResponder()
    
        //Popup success for saving genres
        if dBlimitValue == 0 && intervalValue == 0 {
            _ = SweetAlert().showAlert("Parameters Saved", subTitle: "Decibel Limit = Unset\nInterval Time = Unset", style: AlertStyle.success)
        } else if dBlimitValue == 0 {
            _ = SweetAlert().showAlert("Parameters Saved", subTitle: "Decibel Limit = Unset\nInterval Time = \(intervalValue)", style: AlertStyle.success)
        } else if intervalValue == 0 {
            _ = SweetAlert().showAlert("Parameters Saved", subTitle: "Decibel Limit = \(dBlimitValue)\nInterval Time = Unset", style: AlertStyle.success)
        } else {
            _ = SweetAlert().showAlert("Parameters Saved", subTitle: "Decibel Limit = \(dBlimitValue)\nInterval Time = \(intervalValue)", style: AlertStyle.success)
        }
        
        HomeScreenViewController.dirty = false
        
        _ = navigationController?.popViewController(animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: TextField Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    //Text color function
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.purple
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    //MARK: ViewPicker Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            if row != 0 {
                self.dBlimit1.text = String(NumberFormatter().number(from: pickerData[component][row])!.doubleValue)
                dBlimitValue = NumberFormatter().number(from: pickerData[component][row])!.doubleValue
                dBlimit1.textColor = UIColor.purple
            } else {
                self.dBlimit1.text = "Unset"
                dBlimitValue = 0
                dBlimit1.textColor = UIColor.purple
            }
        case 1:
            if row != 0 {
                self.iTlimit1.text = String(NumberFormatter().number(from: pickerData[component][row])!.doubleValue)
                intervalValue = NumberFormatter().number(from: pickerData[component][row])!.doubleValue
                iTlimit1.textColor = UIColor.purple
            } else {
                self.iTlimit1.text = "Unset"
                intervalValue = 0
                iTlimit1.textColor = UIColor.purple
            }
        default:
            break
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
