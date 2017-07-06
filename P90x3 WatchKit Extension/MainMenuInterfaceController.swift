//
//  InterfaceController.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/1/17.
//

import WatchKit
import Foundation


struct ControllerIdentifier {
    static let tenTimesExerciseWorkoutIdentifier = "TenTimesExerciseWorkoutIdentifier"
    static let thirtySecExerciseWorkoutIdentifier = "ThirtySecExerciseWorkoutIdentifier"
}

class MainMenuInterfaceController: WKInterfaceController {
    let workoutManager = WorkoutManager()
    
    @IBOutlet var workoutsPickerView: WKInterfacePicker!
    var currentlySelectedWorkout: Workout!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        currentlySelectedWorkout = workoutManager.workoutAtIndex(index: 0)
        self.setTitle("P90x3")
        var wkPickerItems = [WKPickerItem]()
        for i in 0...workoutManager.numberOfWorkouts() - 1 {
            let workout = workoutManager.workoutAtIndex(index: i)
            let pickerItem = WKPickerItem()
            pickerItem.title = workout.name
            wkPickerItems.append(pickerItem)
        }
        workoutsPickerView.setItems(wkPickerItems)
    }
    @IBAction func pickerSelected(_ value: Int) {
        currentlySelectedWorkout = workoutManager.workoutAtIndex(index: value)
    }
    
    @IBAction func startButtonPressed() {
        var identifiers = [String]()
        for _ in 0..<currentlySelectedWorkout.excercises.count {
    identifiers.append(ControllerIdentifier.thirtySecExerciseWorkoutIdentifier)
        }
        presentController(withNames: identifiers, contexts: currentlySelectedWorkout.excercises)
    }
    
}
