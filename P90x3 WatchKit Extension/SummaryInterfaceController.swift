//
//  SummaryInterfaceController.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/14/17.
//

import WatchKit
import Foundation
import HealthKit


class SummaryInterfaceController: WKInterfaceController {
    @IBOutlet var workoutTitleLabel: WKInterfaceLabel!
    @IBOutlet var dateLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var durationLabel: WKInterfaceLabel!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var totalCaloriesLabel: WKInterfaceLabel!
    
    var workout: HKWorkout?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        workout = context as? HKWorkout
        setTitle(NSLocalizedString("Summary", comment: "Title for the workout summary view"))
        
    }
    
    override func willActivate() {
        super.willActivate()
        
        guard let workout = workout else { return }
        
        let workoutName = workout.metadata![HKMetadataKeyWorkoutBrandName] as! String
        workoutTitleLabel.setText(workoutName)
        durationLabel.setText(format(duration: workout.duration))
        totalCaloriesLabel.setText(format(totalEnergyBurned: workout.totalEnergyBurned))
        dateLabel.setText(dateDescription(date: workout.startDate))
        timeLabel.setText(timeDescription())
        print(workout.sampleType)
        
        
    }

    @IBAction func doneButtonPressed() {
        WKInterfaceController.reloadRootPageControllers(withNames: ["MainMenuInterfaceControllerIdentifier"],
                                                        contexts: nil,
                                                        orientation: .vertical,
                                                        pageIndex: 0)
    }
    
    func dateDescription(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func timeDescription() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let startDate = workout!.startDate
        let endDate = workout!.endDate
        let startTime = dateFormatter.string(from: startDate)
        let endTime = dateFormatter.string(from: endDate)
        let timeString = "\(startTime) - \(endTime)"
        return timeString
    }
    
}
