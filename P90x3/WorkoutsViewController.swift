//
//  WorkoutsViewController.swift
//  P90x3
//
//  Created by Naman Kedia on 7/2/17.
//

import UIKit

class WorkoutsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var workoutTitleLabel: UILabel!
    @IBOutlet weak var excercisesTableView: UITableView!
    
    let workoutManger = WorkoutManager()
    var currentWorkout: Workout!
    
    var currentWorkoutIndex = 0 {
        didSet {
            currentWorkout = workoutManger.workoutAtIndex(index: currentWorkoutIndex)
            excercisesTableView.reloadData()
            workoutTitleLabel.text = currentWorkout.name
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentWorkout = workoutManger.workoutAtIndex(index: currentWorkoutIndex)
        workoutTitleLabel.text = currentWorkout.name
    }
    
    // MARK: IB Actions
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        if currentWorkoutIndex < workoutManger.numberOfWorkouts() - 1 {
            currentWorkoutIndex = currentWorkoutIndex + 1
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if currentWorkoutIndex > 0 {
            currentWorkoutIndex = currentWorkoutIndex - 1
        }
    }
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWorkout.excercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExcerciseCellIdentifier", for: indexPath)
        cell.textLabel?.text = currentWorkout.excercises[indexPath.row]
        return cell
    }
    
    
    

}
