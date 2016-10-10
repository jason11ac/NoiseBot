//
//  ResultsViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/8/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit
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


class ResultsViewController: UITableViewController {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    var sound: Sound!
    var suggestions = [String]()
    var soundPlayer: AVAudioPlayer!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    //MARK: TableView Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Comments"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return max(1, suggestions.count + 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        
        if (indexPath as NSIndexPath).section == 0 {
            cell.textLabel?.font = UIFont(name: UIFontTextStyle.title1.rawValue, size: 25)
            
            let a = sound.date.index(sound.date.startIndex, offsetBy: 0)..<sound.date.index(sound.date.startIndex, offsetBy: 2)
            let b = sound.date.index(sound.date.startIndex, offsetBy: 3)..<sound.date.index(sound.date.startIndex, offsetBy: 5)
            let c = sound.date.index(sound.date.startIndex, offsetBy: 6)..<sound.date.index(sound.date.endIndex, offsetBy: 0)
            
            let realMonth = month(sound.date[a])
            var realDay = sound.date[b]
            if realDay[realDay.startIndex] == "0" {
                realDay = String(realDay[realDay.index(realDay.startIndex, offsetBy: 1)])
            }
            let realTime = sound.date[c]
            
            if sound.comments.characters.count == 0 {
                cell.textLabel?.font = UIFont(name: "Arial", size: 18)
                cell.textLabel?.text = "\(realMonth) \(realDay)th at \(realTime)\n\nNo comments"
            } else {
                cell.textLabel?.font = UIFont(name: "Arial", size: 18)
                cell.textLabel?.text = "\(realMonth) \(realDay)th at \(realTime)\n\n\(sound.comments!)"
            }
        } else {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            
            if (indexPath as NSIndexPath).row == suggestions.count {
                //Add an extra row for adding suggestions
                cell.textLabel?.text = "Add Comment"
                cell.textLabel?.textColor = UIColor.blue
                cell.selectionStyle = .blue
            } else {
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.text = suggestions[(indexPath as NSIndexPath).row]
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == suggestions.count else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ac = UIAlertController(title: "Add a Comment", message: nil, preferredStyle: .alert)
        var suggestion: UITextField!
        
        ac.addTextField { (textField) -> Void in
            suggestion = textField
            textField.autocorrectionType = .yes
        }
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { (action) -> Void in
            if suggestion.text?.characters.count > 0 {
                self.addSuggestion(suggestion.text!)
            }
            })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    //For showing the proper date
    func month(_ month: String) -> String {
        
        switch month {
        case "01":
            return "January"
        case "02":
            return "February"
        case "03":
            return "March"
        case "04":
            return "April"
        case "05":
            return "May"
        case "06":
            return "June"
        case "07":
            return "July"
        case "08":
            return "August"
        case "09":
            return "September"
        case "10":
            return "October"
        case "11":
            return "November"
        case "12":
            return "December"
        default:
            return ""
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(sound.type!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Records", style: .plain, target: self, action: #selector(sendBackToPublicRecords))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let reference = CKReference(recordID: sound.recordID, action: CKReferenceAction.deleteSelf)
        let pred = NSPredicate(format: "owningSound == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Suggestions", predicate: pred)
        query.sortDescriptors = [sort]
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] (results, error) -> Void in
            if error == nil {
                if let results = results {
                    self.parseResults(results)
                }
            } else {
                //Error handling
                let ac = UIAlertController(title: "Error", message: "There was a problem fetching the suggestions: \(error!.localizedDescription)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Suggestion Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func parseResults(_ records: [CKRecord]) {
        var newSuggestions = [String]()
        
        for record in records {
            newSuggestions.append(record["text"] as! String)
        }
        
        DispatchQueue.main.async {
            self.suggestions = newSuggestions
            self.tableView.reloadData()
        }
    }
    
    func addSuggestion(_ suggest: String) {
        let soundRecord = CKRecord(recordType: "Suggestions")
        let reference = CKReference(recordID: sound.recordID, action: .deleteSelf)
        soundRecord["text"] = suggest as CKRecordValue?
        soundRecord["owningSound"] = reference
        
        CKContainer.default().publicCloudDatabase.save(soundRecord, completionHandler: { [unowned self] (record, error) -> Void in
            DispatchQueue.main.async {
                if error == nil {
                    self.suggestions.append(suggest)
                    self.tableView.reloadData()
                } else {
                    //Error handling
                    let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }) 
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func sendBackToPublicRecords() {
        
        if soundPlayer != nil {
            soundPlayer.stop()
        }
        
        let vc = PublicRecordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //Downloading Cloudkit Data
    func downloadTapped() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.tintColor = UIColor.black
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: sound.recordID) { [unowned self] (record, error) -> Void in
            if error == nil {
                if let record = record {
                    if let asset = record["audio"] as? CKAsset {
                        self.sound.audio = asset.fileURL
                        
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen", style: .plain, target: self, action: #selector(self.listenTapped))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    
                    //Error handling
                    let ac = UIAlertController(title: "Error", message: "There was a problem downloading the audio: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(self.downloadTapped))
                }
            }
        }
    }
    
    func listenTapped() {
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: sound.audio as URL)
            soundPlayer.play()
        } catch {
            //Error handling
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing the audio. Please re-record", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
