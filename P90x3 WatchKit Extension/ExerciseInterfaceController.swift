//
//  ExcerciseWkInterfaceController.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/4/17.
//

import WatchKit
import Foundation


class ExerciseInterfaceController: WKInterfaceController {

    @IBOutlet var workoutTitleLabel: WKInterfaceLabel!
    @IBOutlet var exerciseIndexLabel: WKInterfaceLabel!
    var workout: Workout!
    var index: Int! {
        didSet {
            workoutTitleLabel.setText(workout.excercises[index])
            exerciseIndexLabel.setText("\(index + 1) of \(workout.excercises.count)")
            
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        workout = context as! Workout
        setTitle(workout.name)
        index = 0
    }
    
    @IBAction func nextButtonPressed() {
        if index < workout.excercises.count - 1 {
            index = index + 1
        }
        
    }
    

}
