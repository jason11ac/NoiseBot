//
//  RecordWhistleViewController.swift
//  NoiseBot
//
//  Created by Jason Alvarez-Cohen on 7/7/16.
//  Copyright © 2016 Jason Alvarez-Cohen. All rights reserved.
//

import UIKit
import AVFoundation


//MARK: Global Properties
///////////////////////////////
//User Set Properties
var maxLevel: Double = 0.0
var intervalTime: Double = 0.0

//Global URLS for recording
var audioURLNoise: URL!
var audioURLSilence: URL!
var SilenceLocation: String!
var NoiseLocation: String!
///////////////////////////////



class RecordNoiseViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    //MARK: Properties
    //////////////////////////////////////////////////////////////////////////////////////////
    var stackView: UIStackView!
    var recordButton: UIButton!
    var playButton: UIButton!
    
    var soundPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var soundRecorder: AVAudioRecorder!
    var listener: AVAudioRecorder!
    
    //Listening timers
    var levelTimerSoundRecorder = Timer()
    var levelTimerListener = Timer()
    
    //Decibel Algorithm Variables
    var level: Double!
    let mindB: Double = -60.0
    var counter: Double = 0
    var pause: Double = 0
    var counterStop: Double = 0
    
    //For saved email data and viewpicker data
    let defaults = UserDefaults.standard
    
    //Audio recording settings
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 2 as NSNumber,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ] as [String : Any]
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    

    
    
    
    
    //MARK: View Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    //Load the View
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.alignment = UIStackViewAlignment.center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant:0))
    }
    
    //Recording view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Monitor"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Monitor", style: .plain, target: nil, action: nil)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deleteListenerAudio()
        
        if soundRecorder != nil {
            soundRecorder.stop()
            soundRecorder = nil
        }
        if listener != nil {
            listener.stop()
            listener = nil
        }
        if soundPlayer != nil {
            soundPlayer.stop()
        }
        if levelTimerSoundRecorder.isValid {
            invalidateTimer(levelTimerSoundRecorder)
        }
        if levelTimerListener.isValid {
            invalidateTimer(levelTimerListener)
        }
    }
    
    //Add record button to stackView and load recording UI
    func loadRecordingUI() {
        
        //Record button
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Start Monitoring", for: UIControlState())
        let fontSize = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1).pointSize
        recordButton.titleLabel?.font = UIFont(name: "Futura", size: fontSize)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton)
        
        //Play button
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play Recording", for: UIControlState())
        playButton.isHidden = true
        playButton.alpha = 0
        playButton.titleLabel?.font = UIFont(name: "Futura", size: fontSize)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        stackView.addArrangedSubview(playButton)
    }
    
    //If recording fails
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        failLabel.text = "Monitoring Failed.\nPlease ensure the app has access to your microphone."
        failLabel.numberOfLines = 4
        failLabel.textAlignment = .center
        
        stackView.addArrangedSubview(failLabel)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: Navigation Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func nextTapped() {
        
        //If next is tapped, finish recording
        if soundRecorder != nil {
            finishRecording(success: true)
        }
        
        if soundPlayer != nil {
            soundPlayer.stop()
        }
        
        let vc = ReportViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
   
    

    
    
    
    
    //MARK: Recording Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    //Start the recording
    func startRecording() {
        
        title = "Monitoring"
        
        //Set background to animated red
        //view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = UIColor.red.cgColor
        colorAnimation.toValue = UIColor(red: 255/255, green: 2/255, blue: 15/255, alpha: 0.4).cgColor
        colorAnimation.duration = 1
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = FLT_MAX
        view.layer.add(colorAnimation, forKey: "ColorPulse")
        
        //Set button title when recording
        recordButton.setTitle("Tap to Stop Monitoring", for: UIControlState())
        
        //Get location of file that is saved
        audioURLNoise = RecordNoiseViewController.getNoiseURL()
        NoiseLocation = audioURLNoise.absoluteString
        
        //Record the audio
        do {
            soundRecorder = try AVAudioRecorder(url: audioURLNoise, settings: settings)
            soundRecorder.delegate = self
            soundRecorder.record()
            soundRecorder.isMeteringEnabled = true
            
            if defaults.double(forKey: defaultGlobalKeys1.key1) != 0 {
                maxLevel = defaults.double(forKey: defaultGlobalKeys1.key1)
            }
            
            if defaults.double(forKey: defaultGlobalKeys1.key2) != 0 {
                intervalTime = defaults.double(forKey: defaultGlobalKeys1.key2)
            }

            if (maxLevel != 0 && intervalTime != 0) {
                startSoundRecorderTimer()
            }

            //Reset variables
            counterStop = 0
            pause = 0
            counter = 0
        } catch {
            finishRecording(success: false)
        }
    }
    
    //Level function for soundRecorder
    func soundRecorderLevel() {
        soundRecorder.updateMeters()
        
        let rawdB: Double = Double(soundRecorder.averagePower(forChannel: 0))
        
        //Decibel converting algorithm
        if (rawdB < mindB) {
            level = 0.0
        } else if (rawdB >= 0.0) {
            level = 1.0
        }
        else {
            let root: Double = 2.0
            let minAmp: Double = pow(10.0, (0.05 * mindB))
            let inverse = 1.0 / (1.0 - minAmp)
            let amp: Double = pow(10.0, 0.05 * rawdB)
            let adjAmp: Double = (amp - minAmp) * inverse
            
            level = pow(adjAmp, 1.0 / root)
            level = (level * 120) + 50
            
        }
        
        
        print("Current Level: \(level)")
        print("MaxLevel: \(maxLevel)")
        print("IntervalTime: \(intervalTime)")
        print("Counter: \(counter)")
        print("Pause: \(pause)")
        
        if (level) > maxLevel {
            counter += 0.5
            pause = 0
            
            if counter == intervalTime {
                //Send email to author about incident
                notifyAuthor()
                counter = 0
            }
        } else {
            pause += 0.5
            if pause == 5 {
                print("Start listener")
                soundRecorder.pause()
                listenerFunction()
                invalidateTimer(levelTimerSoundRecorder)
                counter = 0
                pause = 0
            }
        }
    }
    
    //Level function for soundRecorder
    func listenerLevel() {
        listener.updateMeters()
        
        let rawdB: Double = Double(listener.averagePower(forChannel: 0))
        
        //Decibel converting algorithm
        if (rawdB < mindB) {
            level = 0.0
        } else if (rawdB >= 0.0) {
            level = 1.0
        }
        else {
            let root: Double = 2.0
            let minAmp: Double = pow(10.0, (0.05 * mindB))
            let inverse = 1.0 / (1.0 - minAmp)
            let amp: Double = pow(10.0, 0.05 * rawdB)
            let adjAmp: Double = (amp - minAmp) * inverse
            
            level = pow(adjAmp, 1.0 / root)
            level = (level * 120) + 50
        }
        
        print("Current Level: \(level)")
        print("MaxLevel: \(maxLevel)")
        print("IntervalTime: \(intervalTime)")
        print("Counter: \(counter)")
        print("Pause: \(pause)")
        
        if (level) > maxLevel {
            print("Start soundRecorder")
            soundRecorder.record()
            startSoundRecorderTimer()
            invalidateTimer(levelTimerListener)
            listener.stop()
        }
    }
    
    //Set up listener
    func listenerFunction() {
        audioURLSilence = RecordNoiseViewController.getSilenceURL()
        SilenceLocation = audioURLSilence.absoluteString
        
        do {
            listener = try AVAudioRecorder(url: audioURLSilence, settings: settings)
            listener.delegate = self
            listener.record()
            listener.isMeteringEnabled = true
            
            if (maxLevel != 0 && intervalTime != 0) {
                startListenerTimer()
            }
        } catch {
            finishRecording(success: false)
        }
    }
    
    //Finish the recording
    func finishRecording(success: Bool) {
        
        title = "Monitor"
        
        view.layer.removeAllAnimations()
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        
        soundRecorder.stop()
        soundRecorder = nil
        if listener != nil {
            listener.stop()
            listener = nil
            //Delete unneeded listener audio
            deleteListenerAudio()
        }
        
        if levelTimerSoundRecorder.isValid {
            invalidateTimer(levelTimerSoundRecorder)
        }
        if levelTimerListener.isValid {
            invalidateTimer(levelTimerListener)
        }
        
        if success {
            recordButton.setTitle("Tap to Restart Monitoring", for: UIControlState())
            //Show the play button
            if playButton.isHidden {
                UIView.animate(withDuration: 0.35, animations: { [unowned self] in
                    self.playButton.isHidden = false
                    self.playButton.alpha = 1
                }) 
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        } else {
            recordButton.setTitle("Tap to Start Monitoring", for: UIControlState())
            
            let ac = UIAlertController(title: "Monitoring Failed", message: "There was a problem monitoring your noise. Please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    //If recording finished
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    //MARK: Deleting Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    func deleteListenerAudio() {
        
        //Delete unneeded Silence by listener
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if paths.count > 0 {
            let rootPath = paths[0]
            let file = "Silence.m4a"
            let totalPath = NSString(format: "%@/%@", rootPath, file) as String
            if FileManager.default.fileExists(atPath: totalPath) {
                do {
                    try FileManager.default.removeItem(atPath: totalPath)
                    print("Success in deleting silence file")
                } catch {
                    print("Error deleting silence file")
                }
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    //MARK: Notify Author Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    //Push notifications to others when loud for a certain interval
    func notifyAuthor() {
        
        let email = defaults.string(forKey: defaultGlobalKeys1.keyEmail)!
        if (email != "") {
            sendEmailAlert(email)
        }
    }
    
    func sendEmailAlert(_ email: String) {
        let name = defaults.string(forKey: defaultGlobalKeys1.keyName)!
        
       //Create Date
        let todaysDate:Date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: todaysDate)
        if hour > 12 {
            hour = (hour - 12)
        } else if hour == 0 {
            hour = 12
        }
        //Alert Time
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"en_US_POSIX")
        dateFormatter.dateFormat = "\(hour):mma"
        let DateInFormat:String = dateFormatter.string(from: todaysDate)

        //Alert Date
        dateFormatter.dateStyle = DateFormatter.Style.full
        let FullDate:String = dateFormatter.string(from: todaysDate)
        
        
        //MailCore2
        let session = MCOSMTPSession()
        session.hostname = "smtp.gmail.com"
        session.username = "noisebotapp@gmail.com"
        session.password = "Jason11ac847"
        session.port = 465
        session.authType = MCOAuthType.saslPlain
        session.connectionType = MCOConnectionType.TLS
        session.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: email, mailbox: email)]
        builder.header.from = MCOAddress(displayName: "NoiseBot", mailbox: "noisebotapp@gmail.com")
        builder.header.subject = "Incident Occured (\(FullDate))"
        if name != "" {
            builder.textBody = "Dear \(name),\n\nA noise incident that satisfies your settings just occurred at \(DateInFormat)."
        } else {
            builder.textBody = "A noise incident that satisfies your settings just occurred at \(DateInFormat)."
        }
        
        let rfc822Data = builder.data()
        let sendOperation = session.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(error)")
            } else {
                NSLog("Successfully sent email!")
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    //MARK: Tapping Action Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    //Start recording when record button tapped
    func recordTapped() {
        if soundRecorder == nil {
            startRecording()
            if !playButton.isHidden {
                UIView.animate(withDuration: 0.35, animations: { [unowned self] in
                    self.playButton.isHidden = true
                    self.playButton.alpha = 0
                }) 
            }
        } else {
            finishRecording(success: true)
        }
    }
    
    //If play button is tapped
    func playTapped() {
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioURLNoise)
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            soundPlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback Failed", message: "There was a problem playing your noise. Please try re-recording.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    //MARK: Timer Functions
    //////////////////////////////////////////////////////////////////////////////////////////
    //Invalidate/Stop a timer
    func invalidateTimer(_ timer: Timer) {
        timer.invalidate()
    }
    
    //Start soundRecorder Timer
    func startSoundRecorderTimer() {
         levelTimerSoundRecorder = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(soundRecorderLevel), userInfo: nil, repeats: true)
    }
    
    //Start listener Timer
    func startListenerTimer() {
        levelTimerListener = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(listenerLevel), userInfo: nil, repeats: true)
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    
    //MARK: Save Noise Files
    //////////////////////////////////////////////////////////////////////////////////////////
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        
        return documentsDirectory as NSString
    }
    
    class func getNoiseURL() -> URL {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("Noise_File.m4a")
        let audioURL = URL(fileURLWithPath: audioFilename)
        
        return audioURL
    }
    
    class func getSilenceURL() -> URL {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("Silence.m4a")
        let audioURL = URL(fileURLWithPath: audioFilename)
        
        return audioURL
    }
    //////////////////////////////////////////////////////////////////////////////////////////
}
