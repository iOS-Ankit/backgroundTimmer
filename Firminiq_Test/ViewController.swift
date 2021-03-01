//
//  ViewController.swift
//  Firminiq_Test
//
//  Created by Ankit on 12/02/21.
//

import UIKit

enum TimerStatus: String {
    case TimerStarted
    case TimerInvalidate
}

class ViewController: UIViewController {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var startTimer: UIButton!
    @IBOutlet weak var resumeTimer: UIButton!
    @IBOutlet weak var resetTimer: UIButton!
    
    // MARK: Interface Builder Properties
    
    var seconds = 0
    var timer = Timer()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        timerLbl.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stop()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminateNotification), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    func checkIsComingFromBackground() {
        if let status = UserDefaults.standard.value(forKey: "TimerStatus") as? String {
            if status == TimerStatus.TimerStarted.rawValue {
                print("Exiting BACKGROUND >>>>>>>>>>>>")
                let currentTimeStamp = Date().millisecondsSince1970
                if let timeStamp = UserDefaults.standard.value(forKey: "DateTimeStamp") as? Int64 {
                    let additionalMiliSeconds = currentTimeStamp - timeStamp
                    self.seconds += Int(additionalMiliSeconds.miliSecondsToSeconds)
                    print("NEW SECONDS >>>>>>>>>>>>>>", self.seconds)
                }
            }
        }
    }
    
    @objc fileprivate func didEnterBackgroundNotification() {
        let timeStamp = Date().millisecondsSince1970
        if let status = UserDefaults.standard.value(forKey: "TimerStatus") as? String {
            if status == TimerStatus.TimerStarted.rawValue {
                print("GOING BACKGROUND >>>>>>>>>>>>", timeStamp)
                UserDefaults.standard.set(timeStamp, forKey: "DateTimeStamp")
            }
        }
    }
    
    @objc fileprivate func willEnterForegroundNotification() {
        checkIsComingFromBackground()
    }
    
    @objc fileprivate func willTerminateNotification() {
        exitApp()
    }
    
    // MARK: Activate Timer
    
    func start() {
        activateTimer()
    }
    
    func reset() {
        seconds = 0
        stop()
        timerLbl.text = "00:00:00"
    }
    
    func activateTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds += 1
        timerLbl.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i.%02i", hours, minutes, seconds)
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func exitApp() {
        UserDefaults.standard.removeObject(forKey: "TimerStatus")
        UserDefaults.standard.removeObject(forKey: "DateTimeStamp")
        timer.invalidate()
        seconds = 0
    }
    
    // MARK: Interface Builder Actions
    
    @IBAction func startTimerBtnAction(_ sender: UIButton) {
        startTimer.isHidden = true
        resumeTimer.isHidden = false
        resetTimer.isHidden = false
        UserDefaults.standard.set(TimerStatus.TimerStarted.rawValue, forKey: "TimerStatus")
        self.start()
    }
    
    @IBAction func pauseORResumeTimerBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            UserDefaults.standard.set(TimerStatus.TimerInvalidate.rawValue, forKey: "TimerStatus")
            self.stop()
            resumeTimer.setTitle("RESUME", for: .normal)
        } else {
            UserDefaults.standard.set(TimerStatus.TimerStarted.rawValue, forKey: "TimerStatus")
            self.start()
            resumeTimer.setTitle("PAUSE", for: .normal)
        }
    }
    
    @IBAction func resetTimerBtnAction(_ sender: UIButton) {
        startTimer.isHidden = false
        resumeTimer.isHidden = true
        resetTimer.isHidden = true
        UserDefaults.standard.set(TimerStatus.TimerInvalidate.rawValue, forKey: "TimerStatus")
        self.reset()
    }
}

