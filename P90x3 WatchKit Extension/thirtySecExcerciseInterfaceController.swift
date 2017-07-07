//
//  thirtySecExcerciseInterfaceController.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/4/17.
//

import WatchKit
import Foundation


class thirtySecExcerciseInterfaceController: WKInterfaceController {
    
    @IBOutlet var workoutTitleLabel: WKInterfaceLabel!
    @IBOutlet var workoutTimer: WKInterfaceTimer!
    @IBOutlet var startStopButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let exercise = context as! String
        workoutTitleLabel.setText(exercise)
        workoutTimer.setDate(Date(timeIntervalSinceNow: TimeInterval(31.0)))
        workoutTimer.stop()
    }
    @IBAction func startButtonPressed() {
        workoutTimer.setDate(Date(timeIntervalSinceNow: TimeInterval(30.0)))
        workoutTimer.start()
    }
    
}
