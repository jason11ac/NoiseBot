//
//  SubmitViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/7/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import CloudKit
import MessageUI
import AVFoundation
import CoreLocation


//MARK: Global Properties
///////////////////////////////
//Whether submitted to cloud or not (global)
var submit: Bool = false
///////////////////////////////



class SubmitViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    var type: String!
    var comments: String!
    var soundFile: URL!
    
    var toStringEmail = [String]()
    var toStringText = [String]()
    
    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.alignment = UIStackViewAlignment.center
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant:0))

        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Saving Noise Incident"
        status.textColor = UIColor.white
        status.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        status.numberOfLines = 0
        status.textAlignment = .center
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView.addArrangedSubview(status)
        stackView.addArrangedSubview(spinner)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Save Noise Incident"
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if submit == false {
            doSubmission()
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    //MARK: Submission Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func doSubmission() {
        
        soundRecord["type"] = type as CKRecordValue?
        soundRecord["comments"] = comments as CKRecordValue?
        
        //Submission date
        let todaysDate:Date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: todaysDate)
        if hour > 12 {
            hour = (hour - 12)
        } else if hour == 0 {
            hour = 12
        }
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "MM/dd \(hour):mma"
        let DateInFormat:String = dateFormatter.string(from: todaysDate)
        
        soundRecord["dateString"] = DateInFormat as CKRecordValue?
        
        let soundAsset = CKAsset(fileURL: audioURLNoise as URL)
        soundRecord["audio"] = soundAsset
        
        CKContainer.default().publicCloudDatabase.save(soundRecord, completionHandler: { [unowned self] (record, error) -> Void in DispatchQueue.main.async {
            if error == nil {
                //For sending audio links later on
                self.soundFile = audioURLNoise as URL!
                
                PublicRecordViewController.dirty = true
                
                self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                self.status.text = "Saved"
                self.spinner.stopAnimating()
            } else {
                self.status.text = "Error: \(error!.localizedDescription)"
                self.spinner.stopAnimating()
            }
            
            //Submission was attempted
            submit = true
            
            var send: Bool = false
            
            for contact1 in contactsEmail {
                if contact1 != "" {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(self.doneTapped))
                    send = true
                    break
                }
            }
            if send == false {
                for contact2 in contactsText {
                    if contact2 != "" {
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(self.doneTapped))
                        send = true
                        break
                    }
                }
            }
            if send == false {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", style: .plain, target: self, action: #selector(self.doneTapped))
            }
            }
        }) 
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    //MARK: Text Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func sendTexts() {
        
        let messageComposeViewController = configuredMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            self.present(messageComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMessageErrorAlert()
        }
    }

    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        
        for contact in contactsText {
            if contact.isEmpty == false {
                toStringText.append(contact)
            }
        }
        
        CKContainer.default().accountStatus { (accountStat, error) in
            if (accountStat == .noAccount) {
                print("iCloud not available")
                let sendMessageErrorAlert = UIAlertController(title: "Could Not Send Texts", message: "Could not send texts(s) from this device. Please log into iCloud", preferredStyle: .alert)
                sendMessageErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(sendMessageErrorAlert, animated: true, completion: nil)
            } else {
                print("iCloud is available")
            }
        }
        
        //Date and Time Format
        let a = String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 0)..<String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 2)
        let b = String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 3)..<String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 5)
        let c = String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 6)..<String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).endIndex, offsetBy: 0)
        
        let formal = String(describing: soundRecord["dateString"]!)
        
        let realMonth = month(formal[a])
        var realDay = formal[b]
        if realDay[realDay.startIndex] == "0" {
            realDay = String(realDay[realDay.index(realDay.startIndex, offsetBy: 1)])
        }
        let realTime = formal[c]

        messageVC.recipients = toStringText
        messageVC.body = "There was a noise disturbance of type \(type!) at \(soundRecord["address"]!) \(soundRecord["city"]!), \(soundRecord["state"]!) \(soundRecord["zip"]!) on \(realMonth) \(realDay)th at \(realTime).\n\nAdditional Comments: \(comments!)\n\nAttached above is an audio file of the noise."
        messageVC.messageComposeDelegate = self
        
        
        if let fileAttachment = try? Data(contentsOf: soundFile) {
            messageVC.addAttachmentData(fileAttachment, typeIdentifier: "m4a", filename: "Noise_File.m4a")
        }
        
        toStringText.removeAll()
        
        return messageVC
    }
    
    func showSendMessageErrorAlert() {
        let sendMessageErrorAlert = UIAlertController(title: "Could Not Send Text", message: "Could not send text(s) from this device", preferredStyle: .alert)
        sendMessageErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(sendMessageErrorAlert, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result:
        MessageComposeResult) {
        
        switch (result) {
        case MessageComposeResult.cancelled:
            print("Message cancelled")
            self.dismiss(animated: true, completion: nil)
            _ = navigationController?.popToRootViewController(animated: true)
        case MessageComposeResult.failed:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
            _ = navigationController?.popToRootViewController(animated: true)
        case MessageComposeResult.sent:
            print("Message sent")
            self.dismiss(animated: true, completion: nil)
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    
    //MARK: Email Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func sendEmails() {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        for contact in contactsEmail {
            if contact.isEmpty == false {
                toStringEmail.append(contact)
            }
        }
        
        CKContainer.default().accountStatus { (accountStat, error) in
            if (accountStat == .noAccount) {
                print("iCloud not available")
                let sendMessageErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Could not send email(s) from this device. Please log into iCloud", preferredStyle: .alert)
                sendMessageErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(sendMessageErrorAlert, animated: true, completion: nil)
            } else {
                print("iCloud is available")
            }
        }
        
        //Date and Time Format
        let a = String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 0)..<String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 2)
        let b = String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 3)..<String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 5)
        let c = String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).startIndex, offsetBy: 6)..<String(describing: soundRecord["dateString"]!).characters.index(String(describing: soundRecord["dateString"]!).endIndex, offsetBy: 0)
        
        let formal = String(describing: soundRecord["dateString"]!)
        
        let realMonth = month(formal[a])
        var realDay = formal[b]
        if realDay[realDay.startIndex] == "0" {
            realDay = String(realDay[realDay.index(realDay.startIndex, offsetBy: 1)])
        }
        let realTime = formal[c]
        
        mailComposerVC.setToRecipients(toStringEmail)
        mailComposerVC.setSubject("Noise Disturbance of Type: \(type!)")
        mailComposerVC.setMessageBody("There was a noise disturbance of type \(type!) at \(soundRecord["address"]!) \(soundRecord["city"]!), \(soundRecord["state"]!) \(soundRecord["zip"]!) on \(realMonth) \(realDay)th at \(realTime).\n\nAdditional Comments: \(comments!)\n\nAttached below is an audio file of the noise:", isHTML: false)
        
        if let fileAttachment = try? Data(contentsOf: soundFile) {
            mailComposerVC.addAttachmentData(fileAttachment, mimeType: "m4a", fileName: "Noise_File.m4a")
        }
        
        toStringEmail.removeAll()
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result:
        MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        switch (result) {
        case MFMailComposeResult.sent:
            self.dismiss(animated: true, completion: nil)
            
            for contact in contactsText {
                if contact != "" {
                    sendTexts()
                    break
                }
            }
            print("Sent")
        case MFMailComposeResult.saved:
            self.dismiss(animated: true, completion: nil)
            
            for contact in contactsText {
                if contact != "" {
                    sendTexts()
                    break
                }
            }
            print("Saved")
        case MFMailComposeResult.cancelled:
            self.dismiss(animated: true, completion: nil)
            
            for contact in contactsText {
                if contact != "" {
                    sendTexts()
                    break
                }
            }
            print("Cancelled")
        case MFMailComposeResult.failed:
            self.dismiss(animated: true, completion: nil)
            
            for contact in contactsText {
                if contact != "" {
                    sendTexts()
                    break
                }
            }
            print("Failed")
        /*default:
            print("Default")
            self.dismiss(animated: true, completion: nil)
            
            for contact in contactsText {
                if contact != "" {
                    sendTexts()
                    break
                }
            }*/
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Could not send email(s) from this device", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: Date Functions
    //////////////////////////////////////////////////////////////////////////////////////////
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
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func doneTapped() {
        var send: Bool = false

        for contact1 in contactsEmail {
            if contact1 != "" {
                sendEmails()
                send = true
                break
            }
        }
        for contact2 in contactsText {
            if contact2 != "" {
                sendTexts()
                send = true
                break
            }
        }
        if send == false {
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
