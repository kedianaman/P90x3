//
//  WorkoutsViewController.swift
//  P90x3
//
//  Created by Naman Kedia on 7/2/17.
//

import UIKit

class ExerciseListsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .blackOpaque
        navigationController?.navigationBar.tintColor = UIColor.white
        
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
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentWorkoutSegue" {
            let workoutViewController = segue.destination as? WorkoutViewController
            workoutViewController?.workout = currentWorkout
        }
    }
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWorkout.excercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExcerciseCellIdentifier", for: indexPath)
        cell.textLabel?.text = currentWorkout.excercises[indexPath.row]
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
    
    
    

}
