//
//  IntervalDetailViewController.swift
//  Interval Timer
//
//  Created by Hearst, Jacob on 11/18/19.
//  Copyright © 2019 Hearst, Jacob. All rights reserved.
//

import UIKit

class IntervalDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var interval: Interval?

    @IBOutlet weak var intervalNameInput: UITextField!
    @IBOutlet weak var timerPickerView: UIPickerView!
    @IBOutlet weak var intervalTypePicker: UISegmentedControl!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.intervalNameInput.text = self.interval?.name
        self.navigationItem.hidesBackButton = true

        initPickerView()
    }
    
    // MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 2 }
    
    // Components in row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 60 }
    
    // Label for row item
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row) \(component == 0 ? "min" : "sec")"
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UnwindIntervalEdit") {
            let intervalViewController = segue.destination as! IntervalViewController
            let newInterval = Interval(context: intervalViewController.managedContext)
            newInterval.name = intervalNameInput.text!
            newInterval.length = getIntervalLength()
            newInterval.type = Int16(intervalTypePicker.selectedSegmentIndex)

            if (interval != nil) {
                intervalViewController.updateInterval(newInterval)
            } else {
                guard (newInterval.name?.count ?? 0) > 0 && newInterval.length > 0 else { return }
                intervalViewController.createInterval(newInterval)
            }
        }
    }
    
    // MARK: Other
    func initPickerView() {
        self.timerPickerView.dataSource = self
        self.timerPickerView.delegate = self
        
        guard let interval = interval else {
            timerPickerView.selectRow(1, inComponent: 1, animated: false)
            return
        }
        let minutes = Int(interval.length / 60)
        let seconds = Int(interval.length % 60)
        
        self.timerPickerView.selectRow(minutes, inComponent: 0, animated: false)
        self.timerPickerView.selectRow(seconds, inComponent: 1, animated: false)
    }
    
    func getIntervalLength() -> Int16 {
        let minutes = timerPickerView.selectedRow(inComponent: 0)
        let seconds = timerPickerView.selectedRow(inComponent: 1)

        return Int16((minutes * 60) + seconds)
    }
}
