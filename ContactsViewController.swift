//
//  ContactsViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 8/25/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import ContactsUI
import AddressBook


//MARK: Global Properties
///////////////////////////////
//Global contact arrays
var contacts = [CNContact]()
var contactsEmail = [String]()
var contactsText = [String]()
var contactRow: Int!
///////////////////////////////



class ContactsViewController: UITableViewController, CNContactPickerDelegate {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    var objects = [CNContact]()
    var objectsText = [CNContact]()
    var objectsEmail = [CNContact]()
    //////////////////////////////////////////////////////////////////////////////////////////

    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Contacts to Notify"
        
        //For Contact cells
        tableView.register(UITableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: "CellContact")
        
        NotificationCenter.default.addObserver(self, selector: #selector(insertNewObject(_:)), name: NSNotification.Name(rawValue: "addNewContact"), object: nil)
            self.getContacts()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        
        
        //Tool Bar:
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(title: "Add Existing", style: .plain, target: self, action: #selector(addExistingContact)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(title: "Create New", style: .plain, target: self, action: #selector(createContact)))
        
        toolbarItems = items
        
        contactsText.removeAll()
        contactsEmail.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func donePressed() {
        
        let vc = SelectSoundTypeController()
        navigationController?.pushViewController(vc, animated: true)
        
        //Add contacts to a global array for sending later
        contacts = objects
    }
    
    func createContact() {
        
        let vc = CreateContactViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func addExistingContact() {
        determineStatus()
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    //MARK: Contact Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store)
                }
            } as! (Bool, Error?) -> Void)
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store)
        }
    }
    
    func retrieveContactsWithStore(_ store: CNContactStore) {
        do {
            let groups = try store.groups(matching: nil)
            let predicate = CNContact.predicateForContactsInGroup(withIdentifier: groups[0].identifier)
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactEmailAddressesKey, CNContactPhoneNumbersKey] as [Any]
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            self.objects = contacts
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        } catch {
            print(error)
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addNewContact"), object: nil, userInfo: ["contactToAdd": contact])
    }
    
    func determineStatus() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            //Authorized access
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            self.present(contactPicker, animated: true, completion: nil)
        case .notDetermined:
            //Not asked user yet
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                guard granted && error == nil else {
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: "Contacts Failed", message: "NoiseBot needs permission to access your contacts while the app is in use. Please allow this in settings.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(ac, animated: true, completion: nil)
                    }
                    return
                }
            }
        case .denied, .restricted:
            //Denied access
            let ac = UIAlertController(title: "Contacts Failed", message: "NoiseBot needs permission to access your contacts while the app is in use. Please allow this in settings.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    //Inset the new contact
    func insertNewObject(_ sender: Notification) {
        if let contact = (sender as NSNotification).userInfo?["contactToAdd"] as? CNContact {
            objects.insert(contact, at: 0)
            
            let email = contact.emailAddresses.first?.value as? String
            let number = (contact.phoneNumbers.first?.value)! as CNPhoneNumber
            
            if email != nil && email != "" {
                contactsEmail.insert(email!, at: 0)
            } else {
                contactsEmail.insert("", at: 0)
            }
            if number.stringValue.isEmpty == false {
                contactsText.insert(number.stringValue, at: 0)
            } else {
                contactsText.insert("", at: 0)
            }
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: TableView Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CellContact")
        
        let contact = self.objects[(indexPath as NSIndexPath).row]
        let formatter = CNContactFormatter()
        
        cell.textLabel?.text = formatter.string(from: contact)
        
        let email = contact.emailAddresses.first?.value as? String
        let number = (contact.phoneNumbers.first?.value)! as CNPhoneNumber
        
        //If no email or number
        if (email == nil || email == "") && (number.stringValue.isEmpty == true) {
            cell.detailTextLabel?.text = ""
        }
            //If no email
        else if (email == nil || email == "") && (number.stringValue.isEmpty == false) {
            cell.detailTextLabel?.text = "\(number.stringValue)"
        }
            //If no number
        else if (email != nil && email != "") && (number.stringValue.isEmpty == true) {
            cell.detailTextLabel?.text = email!
        }
            //If both provided
        else {
            cell.detailTextLabel?.text = "\(email!), \(number.stringValue)"
        }
        return cell
    }
    
    //Deleting a contact from the list functions
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            objects.remove(at: (indexPath as NSIndexPath).row)
            contactsEmail.remove(at: (indexPath as NSIndexPath).row)
            contactsText.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            contactRow = (indexPath as NSIndexPath).row
            
            let object = objects[(indexPath as NSIndexPath).row]
            let controller = DetailTableViewController()
            
            let formatter = CNContactFormatter()
            controller.name = formatter.string(from: object)
            
            controller.contact = object
            
            let email = object.emailAddresses.first?.value as? String
            let number = (object.phoneNumbers.first?.value)! as CNPhoneNumber
            
            if (email == nil || email == "") && (number.stringValue.isEmpty == true) {
                controller.email = nil
                controller.number = nil
                controller.items = 0
            }
                //If no email
            else if (email == nil || email == "") && (number.stringValue.isEmpty == false) {
                controller.number = number.stringValue
                controller.email = nil
                controller.items = 1
            }
                //If no number
            else if (email != nil && email != "") && (number.stringValue.isEmpty == true) {
                controller.email = email!
                controller.number = nil
                controller.items = 2
            }
                //If both provided
            else {
                controller.email = email!
                controller.number = number.stringValue
                controller.items = 3
            }
            navigationController?.pushViewController(controller, animated: true)
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}

