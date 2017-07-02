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
    var workoutIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let workout = workoutManger.workoutAtIndex(index: 0)
        return workout.excercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ExcerciseCellIdentifier")
        cell.textLabel?.text = workoutManger.workoutAtIndex(index: workoutIndex).excercises[indexPath.row]
        return cell
    }
    

    

}
