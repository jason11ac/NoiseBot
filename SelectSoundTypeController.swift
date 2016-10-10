//
//  SelectSoundTypeController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/7/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SelectSoundTypeController: UITableViewController {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    static var types = ["Unknown", "Aircraft", "Animal", "Construction", "Machine", "Music", "Party", "Vehicle", "Yelling"]
    
    var other: UITextField!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    

    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Noise Type"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Type", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    //////////////////////////////////////////////////////////////////////////////////////////

    
    
    
    
    
    
    //MARK: TableView Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return SelectSoundTypeController.types.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Configure the cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if (indexPath as NSIndexPath).row != SelectSoundTypeController.types.count {
            cell.textLabel?.text = SelectSoundTypeController.types[(indexPath as NSIndexPath).row]
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = "Set Other"
            cell.textLabel?.textColor = UIColor.blue
            cell.selectionStyle = .blue
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row == SelectSoundTypeController.types.count {
            let vc = AddCommentsViewController()
            let ac = UIAlertController(title: "Set Other", message: nil, preferredStyle: .alert)
            ac.addTextField { (textField) -> Void in
                textField.autocorrectionType = .yes
                self.other = textField
            }
            ac.addAction(UIAlertAction(title: "Submit", style: .default) { (action) -> Void in
                if self.other.text?.characters.count > 0 {
                    vc.type = self.other.text
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    ac.dismiss(animated: true, completion: nil)
                }
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
            
        } else {
            if let cell = tableView.cellForRow(at: indexPath) {
                let Type = cell.textLabel?.text ?? SelectSoundTypeController.types[0]
                let vc = AddCommentsViewController()
                vc.type = Type
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
