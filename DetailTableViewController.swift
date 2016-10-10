//
//  DetailTableViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/3/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class DetailTableViewController: UITableViewController {

    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    var name: String!
    var email: String!
    var number: String!
    
    var contact: CNContact!
    
    var items: Int!
    var contactItems = ["", ""]
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        
        //If nothing
        if (email == nil || email == "") && (number == nil || number == "") {
            //Do nothing
        }
        //If no email
        else if (email == nil || email == "") && (number != nil && number != "") {
            contactItems[0] = number
        }
        //If no number
        else if (email != nil && email != "") && (number == nil || number == "") {
            contactItems[0] = email
        }
        //If both provided
        else {
            contactItems[0] = email
            contactItems[1] = number
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func saveTapped() {
    
        _ = SweetAlert().showAlert("\(name!)", subTitle: "Notification settings saved.", style: AlertStyle.success)
        _ = navigationController?.popViewController(animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////

    
    
    
    
    
    
    
    
    //MARK: TableView Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch items {
        case 0:  //No email or number
            return 0
        case 1, 2:  //Just a number or just an email
            return 1
        case 3:  //Both email and number provided
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            
            if cell.accessoryType == .none {
                if items == 1 { //Just number
                    cell.accessoryType = .checkmark
                    contactsText[contactRow] = number
                }
                else if items == 2 { //Just Email
                    cell.accessoryType = .checkmark
                    contactsEmail[contactRow] = email
                }
                else if items == 3 { //Both number and email
                    cell.accessoryType = .checkmark
                    if (indexPath as NSIndexPath).row == 0 {
                        contactsEmail[contactRow] = email
                    }
                    else if (indexPath as NSIndexPath).row == 1 {
                        contactsText[contactRow] = number
                    }
                }
            } else {
                if items == 1 { //Just number
                    cell.accessoryType = .none
                    contactsText[contactRow] = ""
                }
                else if items == 2 { //Just Email
                    cell.accessoryType = .none
                    contactsEmail[contactRow] = ""
                }
                else if items == 3 { //Both number and email
                    cell.accessoryType = .none
                    if (indexPath as NSIndexPath).row == 0 {
                        contactsEmail[contactRow] = ""
                    }
                    else if (indexPath as NSIndexPath).row == 1 {
                        contactsText[contactRow] = ""
                    }
                }
            }
        tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let info = contactItems[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = info
        
        if items == 1 { //Just number
            for contacts in contactsText {
                if number == contacts {
                    cell.accessoryType = .checkmark
                    break
                }
            }
        }
        if items == 2 { //Just email
            for contacts in contactsEmail {
                if email == contacts {
                    cell.accessoryType = .checkmark
                    break
                }
            }
        }
        if items == 3 { //Both number and email
            if (indexPath as NSIndexPath).row == 0 {
                for contacts in contactsEmail {
                    if email == contacts {
                        cell.accessoryType = .checkmark
                        break
                    }
                }
            } else {
                for contacts in contactsText {
                    if number == contacts {
                        cell.accessoryType = .checkmark
                        break
                    }
                }
            }
        }
        return cell
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
