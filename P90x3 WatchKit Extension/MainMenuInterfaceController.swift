//
//  InterfaceController.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/1/17.
//

import WatchKit
import Foundation
import HealthKit


struct ControllerIdentifier {
    static let ExerciseICIdentifier = "ExerciseInterfaceControllerIdentifer"
    static let WorkoutICIdentifier = "WorkoutInterfaceControllerIdentifier"
}

class MainMenuInterfaceController: WKInterfaceController {
    let workoutManager = WorkoutManager()
    
    @IBOutlet var workoutsPickerView: WKInterfacePicker!
    var currentlySelectedWorkout: Workout!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        currentlySelectedWorkout = workoutManager.workoutAtIndex(index: 0)
        self.setTitle("P90x3")
        
        // Populate picker
        let wkPickerItems: [WKPickerItem] = workoutManager.allWorkouts().map { workout in
            let pickerItem = WKPickerItem()
            pickerItem.title = workout.name
            return pickerItem
        }
        workoutsPickerView.setItems(wkPickerItems)
    }
    @IBAction func pickerItemChanged(_ value: Int) {
        currentlySelectedWorkout = workoutManager.workoutAtIndex(index: value)
    }
    
    
    @IBAction func startButtonPressed() {
        WKInterfaceController.reloadRootPageControllers(withNames: [ControllerIdentifier.WorkoutICIdentifier, ControllerIdentifier.ExerciseICIdentifier], contexts: [currentlySelectedWorkout, currentlySelectedWorkout], orientation: .horizontal, pageIndex: 0)
    }
    
}
