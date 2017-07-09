/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Interface controller for the workout summary screen.
*/

import WatchKit
import Foundation
import HealthKit

class SummaryInterfaceController: WKInterfaceController {

    // MARK: - Properties

    var workout: HKWorkout?

    // MARK: - IB Outlets

    @IBOutlet private var workoutLabel: WKInterfaceLabel!
    @IBOutlet private var durationLabel: WKInterfaceLabel!
    @IBOutlet private var caloriesLabel: WKInterfaceLabel!
    @IBOutlet private var distanceLabel: WKInterfaceLabel!

    // MARK: - Interface Controller Overrides

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        workout = context as? HKWorkout

        setTitle(NSLocalizedString("Summary", comment: "Title for the workout summary view"))
    }

    override func willActivate() {
        super.willActivate()

        guard let workout = workout else { return }

        var workoutTitle = WorkoutType(workout.workoutActivityType).displayString()
        if let isIndoor = workout.metadata?[HKMetadataKeyIndoorWorkout] as? Bool {
            let locationType = isIndoor ? LocationType.indoor : LocationType.outdoor
            let formatString = NSLocalizedString("LOCATION_TYPE_%@_WORKOUT_TYPE_%@",
                                                 comment: "Title for workout type with location type prefix")
            workoutTitle = String(format: formatString, locationType.displayString(), workoutTitle)
        }

        workoutLabel.setText(workoutTitle)
        caloriesLabel.setText(format(totalEnergyBurned: workout.totalEnergyBurned))
        distanceLabel.setText(format(totalDistance: workout.totalDistance))
        durationLabel.setText(format(duration: workout.duration))
    }

    @IBAction private func didTapDoneButton() {
        WKInterfaceController.reloadRootPageControllers(withNames: ["ConfigurationInterfaceController"],
                                                        contexts: nil,
                                                        orientation: .vertical,
                                                        pageIndex: 0)
    }
}
