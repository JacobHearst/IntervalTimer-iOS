//
//  IntervalViewController.swift
//  Interval Timer
//
//  Created by Hearst, Jacob on 11/18/19.
//  Copyright © 2019 Hearst, Jacob. All rights reserved.
//

import UIKit
import CoreData

class IntervalViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    var managedContext: NSManagedObjectContext!
    var workout: Workout!
    var intervals: [Interval] = []
    
    var selectedInterval: Interval?
    var defaultTitleView: UIView?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startTimerButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = workout.name
        defaultTitleView = navigationItem.titleView
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedContext = appDelegate.persistentContainer.viewContext

        intervals = workout.intervals?.allObjects as? [Interval] ?? []
        intervals = intervals.sorted(by: {$0.listIndex < $1.listIndex})
        
        startTimerButton.isEnabled = intervals.count > 0
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }
    
    // Display of cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath)
        
        let interval = intervals[indexPath.row]
        cell.textLabel?.text = interval.name
        cell.detailTextLabel?.text = formatTime(interval.length)
        
        return cell
    }
    
    // Select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedInterval = intervals[indexPath.row]
        performSegue(withIdentifier: "ViewIntervalDetail", sender: nil)
    }
    
    // Reorder
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedInterval = intervals.remove(at: fromIndexPath.row)
        intervals.insert(movedInterval, at: to.row)
        intervalListUpdated()
    }
    
    // Delete (Edit)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let deletedInterval = intervals.remove(at: indexPath.row)
        managedContext.delete(deletedInterval as NSManagedObject)
        updateWorkoutTime(oldInterval: deletedInterval, newInterval: nil)
        intervalListUpdated()
    }
    
    // On swipe
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.isEditing = true
        editButton.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ViewIntervalDetail") {
            let intervalDetailViewController = segue.destination as! IntervalDetailViewController
            intervalDetailViewController.interval = selectedInterval
        } else if (segue.identifier == "StartTimer") {
            let timerViewController = segue.destination as! TimerViewController
            timerViewController.intervals = intervals
        }
    }
    
    @IBAction func unwindFromDetailView(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func unwindFromTimerView(unwindSegue: UIStoryboardSegue) {}
    
    // MARK: Action Outlets
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        sender.title = tableView.isEditing ? "Done" : "Edit"
        toggleEditableTitle(tableView.isEditing)
    }
    
    // MARK: Other
    func toggleEditableTitle(_ isEditable: Bool) {
        if (isEditable) {
            let textField = UITextField()
            textField.text = navigationItem.title
            textField.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
            textField.borderStyle = .roundedRect
            textField.textAlignment = .center
            self.navigationItem.titleView = textField
        } else {
            guard navigationItem.titleView is UITextField else { return }

            let newTitle = (navigationItem.titleView as! UITextField).text
            navigationItem.titleView = self.defaultTitleView

            title = newTitle
            workout.name = newTitle
            saveCoreData(managedContext)
        }
    }
    
    func updateInterval(_ newInterval: Interval) {
        guard let oldInterval = selectedInterval else { return }

        updateWorkoutTime(oldInterval: oldInterval, newInterval: newInterval)

        oldInterval.name = newInterval.name
        oldInterval.length = newInterval.length
        oldInterval.type = newInterval.type

        intervalListUpdated()
    }
    
    func createInterval(_ interval: Interval) {
        interval.workout = workout
        interval.listIndex = Int16(intervals.count)

        intervals.append(interval)
        updateWorkoutTime(oldInterval: nil, newInterval: interval)

        intervalListUpdated()
    }
    
    func updateWorkoutTime(oldInterval: Interval?, newInterval: Interval?) {
        workout.length += (newInterval?.length ?? 0) - (oldInterval?.length ?? 0)
    }
    
    func intervalListUpdated() {
        startTimerButton.isEnabled = intervals.count > 0
        persistIndexUpdates()
        saveCoreData(managedContext)
        tableView.reloadData()
    }
    
    func persistIndexUpdates() {
        intervals.enumerated().forEach { (arg0) in
            let (offset, interval) = arg0
            interval.listIndex = Int16(offset)
        }
        saveCoreData(managedContext)
    }
}
