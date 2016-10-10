//
//  PublicRecordViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/7/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import CloudKit
import AVFoundation


class PublicRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    //Table of records
    var tableView: UITableView!
    
    static var dirty: Bool = false
    
    //Array of sounds for table
    var sounds = [Sound]()
    var refreshControl: UIRefreshControl!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    // MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.white
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: .alignAllCenterX, metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[guide][tableView]|", options: .alignAllCenterX, metrics: nil, views: ["guide": topLayoutGuide, "tableView": tableView]))
        
        //Fixes the table view problem
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Noise Public Record"
        
        PublicRecordViewController.dirty = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Records", style: .plain, target: nil, action: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull Down to Refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(backToHome))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        loadSounds()
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func addSound() {
        let vc = MapViewController()
        self.tableView.reloadData()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func backToHome() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Cell Format
    //////////////////////////////////////////////////////////////////////////////////////////
    func makeAttributedString(title: String, subtitle: String, subtitle2: String, placetitle: String) -> NSAttributedString {
        
        //For type
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline), NSForegroundColorAttributeName: UIColor.blue]
        
        //For comments
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        
        //For date
        let datetitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1), NSForegroundColorAttributeName: UIColor(red: 19/255, green: 142/255, blue: 255/255, alpha: 1.0)]
        
        //For location
        let placetitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1), NSForegroundColorAttributeName: UIColor(red: 0/255, green: 166/255, blue: 1/255, alpha: 1.0)]
        
        //Date
        let titleString = NSMutableAttributedString(string: "\(title)", attributes: datetitleAttributes)
        
        //Type
        let subtitleString = NSAttributedString(string: "\n\(subtitle)", attributes: titleAttributes)
        titleString.append(subtitleString)

        //Comments
        if subtitle2.characters.count > 0 {
            let subtitle2String = NSAttributedString(string: "\n\(subtitle2)", attributes: subtitleAttributes)
            titleString.append(subtitle2String)
        }
        
        //Location
        let placeString = NSAttributedString(string: "\n\(placetitle)", attributes: placetitleAttributes)
        titleString.append(placeString)
        
        
        return titleString
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    //MARK: Swiping/Editing Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let map = UITableViewRowAction(style: .normal, title: "Location") { (action, indexPath) in
            let vc = ShowSoundLocationViewController()
            vc.sound = self.sounds[(indexPath as NSIndexPath).row]
            vc.lat = self.sounds[(indexPath as NSIndexPath).row].lat
            vc.long = self.sounds[(indexPath as NSIndexPath).row].long
            self.tableView.reloadData()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        map.backgroundColor = UIColor(red: 0/255, green: 166/255, blue: 1/255, alpha: 1.0)
        
        return [map]
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
        self.tableView.setEditing(false, animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    //MARK: TableView Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let location = "\(sounds[(indexPath as NSIndexPath).row].city!), \(sounds[(indexPath as NSIndexPath).row].state!)"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.attributedText = makeAttributedString(title: sounds[(indexPath as NSIndexPath).row].date, subtitle: sounds[(indexPath as NSIndexPath).row].type , subtitle2: sounds[(indexPath as NSIndexPath).row].comments, placetitle: location)
        
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sounds.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPAth: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ResultsViewController()
        vc.sound = sounds[(indexPath as NSIndexPath).row]
        navigationController?.pushViewController(vc, animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: Refresh and Reload Sounds
    //////////////////////////////////////////////////////////////////////////////////////////
    func refresh(sender: AnyObject) {
        loadSounds()
    }
    
    func loadSounds() {
        
        submit = false
        
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Sound", predicate: pred)
        
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["type", "comments", "dateString", "city", "state", "lat", "long"]
        operation.resultsLimit = 50
        
        var newSounds = [Sound]()
        
        operation.recordFetchedBlock = { (record) in
            let sound = Sound()
            sound.recordID = record.recordID
            sound.type = record["type"] as! String
            sound.comments = record["comments"] as! String
            sound.date = record["dateString"] as! String
            sound.city = record["city"] as! String
            sound.state = record["state"] as! String
            sound.lat = record["lat"] as! Double
            sound.long = record["long"] as! Double
            
            newSounds.append(sound)
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.sounds = newSounds
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of sounds. Please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
        refreshControl.endRefreshing()
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}

