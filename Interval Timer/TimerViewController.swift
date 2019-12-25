//
//  TimerViewController.swift
//  Interval Timer
//
//  Created by Hearst, Jacob on 11/19/19.
//  Copyright © 2019 Hearst, Jacob. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var upNextLabel: UILabel!
    
    var intervals: [Interval]!
    var timer: Timer?
    var timeLeft = 0
    var isPaused = true
    var currIntervalIndex: Int! {
        didSet {
            let interval = intervals[currIntervalIndex]
            timeLeft = Int(interval.length)
            displayInterval(interval)
        }
    }
    var currInterval: Interval {
        return intervals[currIntervalIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currIntervalIndex = 0
    }
    
    @IBAction func playPause(_ sender: UIButton) {
        if (isPaused) {
            sender.setImage(UIImage(named: "pause"), for: .normal)
            if (timeLeft == currInterval.length) {
                startInterval(currInterval)
            } else {
                resumeInterval()
            }
        } else {
            sender.setImage(UIImage(named: "play"), for: .normal)
            timer?.invalidate()
        }

        isPaused = !isPaused
    }
    
    @IBAction func rewind(_ sender: Any) {
        if (Int(currInterval.length) - timeLeft <= 1) {
            if (currIntervalIndex != 0) {
                currIntervalIndex -= 1
            }
        }
        
        displayInterval(currInterval)
        
        if (!isPaused) {
            startInterval(currInterval)
        }
    }

    @IBAction func fastForward(_ sender: Any) {
        guard currIntervalIndex < intervals.count - 1 else { return endWorkout() }
        currIntervalIndex += 1
        
        if (!isPaused) {
            startInterval(currInterval)
        }
    }
    
    func startInterval(_ interval: Interval) {
        timer?.invalidate()

        if (timer == nil) {
            timeLeft = Int(interval.length)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        } else {
            if (!timer!.isValid) {
                timeLeft = Int(interval.length)
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            }
        }
    }
    
    func resumeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func displayInterval(_ interval: Interval) {
        if (toIntervalTypeEnum(interval.type) == IntervalType.ACTIVE) {
            rootView.backgroundColor = .green
        } else {
            rootView.backgroundColor = .yellow
        }
        
        exerciseNameLabel.text = interval.name
        
        var upNext = "Up next: "
        if (currIntervalIndex + 1 >= intervals.count) {
            upNext += "Done"
        } else {
            upNext += intervals?[currIntervalIndex+1].name ?? "Empty"
        }
        upNextLabel.text = upNext
        timerLabel.text = formatTime(interval.length)
    }
    
    @objc func updateTime() {
        guard timeLeft != 0 else { return endInterval() }
        timeLeft -= 1

        timerLabel.text = "\(formatTime(Int16(timeLeft)))"
    }
    
    func endInterval() {
        guard currIntervalIndex < intervals.endIndex - 1 else { return endWorkout() }
        currIntervalIndex += 1
        startInterval(currInterval)
    }
    
    func endWorkout() {
        timer?.invalidate()
        performSegue(withIdentifier: "TimerViewUnwind", sender: self)
    }
}
