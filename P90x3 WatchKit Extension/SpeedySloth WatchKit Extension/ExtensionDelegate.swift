/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Watch Kit Extension delegate.
*/

import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    // MARK: - WKExtensionDelegate

    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        WKInterfaceController.reloadRootPageControllers(withNames: ["WorkoutInterfaceController"],
                                                        contexts: [workoutConfiguration],
                                                        orientation: .vertical,
                                                        pageIndex: 0)
    }
}
