//
//  WorkoutTableViewController.swift
//  Interval Timer
//
//  Created by Hearst, Jacob on 11/18/19.
//  Copyright © 2019 Hearst, Jacob. All rights reserved.
//

import UIKit
import CoreData

class WorkoutTableViewController: UITableViewController {
    var managedContext: NSManagedObjectContext!
    var workouts: [Workout] = []
    var selectedWorkout: Workout?

    @IBOutlet var newWorkoutNameField: UITextField?
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Workout")
          
        do {
            workouts = try managedContext.fetch(fetchRequest) as! [Workout]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedContext = appDelegate.persistentContainer.viewContext
        
        tableView.reloadData()
    }

    // MARK: TableView
    // Count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return workouts.count }

    // Create cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)

        let workout = workouts[indexPath.row]
        cell.textLabel?.text = workout.name
        cell.detailTextLabel?.text = formatTime(workout.length)

        return cell
    }

    // Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        managedContext.delete(workouts[indexPath.row] as NSManagedObject)
        saveCoreData(managedContext)
        workouts.remove(at: indexPath.row)
        self.tableView.reloadData()
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedWorkout = workouts.remove(at: fromIndexPath.row)
        workouts.insert(movedWorkout, at: to.row)
        tableView.reloadData()
    }
    
    // On Tap
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedWorkout = workouts[indexPath.row]
        performSegue(withIdentifier: "ViewWorkout", sender: nil)
    }
    
    // Disable reordering
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { return false }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ViewWorkout") {
            let intervalViewController = segue.destination as! IntervalViewController
            intervalViewController.workout = self.selectedWorkout
        }
    }

    // MARK: Action Outlets
    @IBAction func addWorkoutClicked(_ sender: Any) {
        // TODO: Add validation so that an empty input can't be saved
        let alert = UIAlertController(title: "Create New Workout", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: createWorkout(action:)))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Workout name"
            self.newWorkoutNameField = textField
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Other
    func createWorkout(action: UIAlertAction) {
        guard let workoutName = self.newWorkoutNameField?.text else { return }

        let workout = Workout(context: managedContext)
        workout.name = workoutName
        workout.length = 0
        
        saveCoreData(managedContext)
        workouts.append(workout)
        self.tableView.reloadData()
    }
}
