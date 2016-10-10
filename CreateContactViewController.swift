//
//  CreateContactViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/28/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import Contacts

class CreateContactViewController: UIViewController, UITextFieldDelegate {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    //MARK: Get/Create New Contact
    //////////////////////////////////////////////////////////////////////////////////////////
    var newContact: CNContact {
        get {
            let store = CNContactStore()
            
            let contactToAdd = CNMutableContact()
            contactToAdd.givenName = self.firstNameField.text ?? ""
            contactToAdd.familyName = self.lastNameField.text ?? ""
            
            let mobileNumber = CNPhoneNumber(stringValue: (self.numberField.text ?? ""))
            let mobileValue = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: mobileNumber)
            contactToAdd.phoneNumbers = [mobileValue]
            
            //let emailString: NSString = self.emailField.text as NSString? ?? ""
            //let email = CNLabeledValue(label: CNLabelHome, value: (emailString as NSCopying))
            //contactToAdd.emailAddresses = [email]
            
            let saveRequest = CNSaveRequest()
            
            if (contactToAdd.givenName == "" && contactToAdd.familyName == "") {
                return contactToAdd
            } else {
                saveRequest.add(contactToAdd, toContainerWithIdentifier: nil)
            }
            do {
                try store.execute(saveRequest)
            } catch {
                print(error)
            }
            
            return contactToAdd
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Contact"
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        numberField.delegate = self
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func doneTapped() {
        
        firstNameField.textColor = UIColor.green
        lastNameField.textColor = UIColor.green
        emailField.textColor = UIColor.green
        numberField.textColor = UIColor.green
    
        if firstNameField.text == "" && lastNameField.text == "" {
            //Do not create contact
        } else {
            //Create Contact
            NotificationCenter.default.post(name: Notification.Name(rawValue: "addNewContact"), object: nil, userInfo: ["contactToAdd": self.newContact])
            _ = SweetAlert().showAlert("Contact Created", subTitle: nil, style: AlertStyle.success)

        }
        _ = navigationController?.popViewController(animated: true)
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        numberField.resignFirstResponder()
        
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: TextField Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
