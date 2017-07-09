/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Interface controller for the configuration screen.
*/

import WatchKit
import Foundation
import HealthKit

class ConfigurationInterfaceController: WKInterfaceController {

    // MARK: - Properties

    private let healthStore = HKHealthStore()
    private let activityTypes: [WorkoutType] = [.walking, .running, .hiking]
    private let locationTypes: [LocationType] = [.outdoor, .indoor]

    private var selectedActivityType: WorkoutType
    private var selectedLocationType: LocationType

    // MARK: - IB Outlets

    @IBOutlet var activityTypePicker: WKInterfacePicker!
    @IBOutlet var locationTypePicker: WKInterfacePicker!

    // MARK: - Initialization

    override init() {
        selectedActivityType = activityTypes[0]
        selectedLocationType = locationTypes[0]

        super.init()
    }

    // MARK: - Interface Controller Overrides

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        setTitle(NSLocalizedString("Speedy Sloth", comment: "Title with application name"))

        // Populate the activity type picker
        let activityTypePickerItems: [WKPickerItem] = activityTypes.map { type in
            let pickerItem = WKPickerItem()
            pickerItem.title = type.displayString()
            return pickerItem
        }
        activityTypePicker.setItems(activityTypePickerItems)

        // Populate the location type picker
        let locationTypePickerItems: [WKPickerItem] = locationTypes.map { type in
            let pickerItem = WKPickerItem()
            pickerItem.title = type.displayString()
            return pickerItem
        }
        locationTypePicker.setItems(locationTypePickerItems)
    }

    // MARK: - Post processing of workouts (Slothify)

    private func makeWorkoutsSlothy() {
        loadWorkouts { workouts in
            for workout in workouts {
                self.makeWorkoutSlothy(workout)
            }
        }
    }

    private func loadWorkouts(completion: @escaping (_ workouts: [HKWorkout]) -> Void) {
        // Query for all workouts created with this app
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForObjects(from: HKSource.default())
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, results, error in
            guard let workouts = results as? [HKWorkout] else {
                print("An error occured: \(error?.localizedDescription ?? "Unknown")")
                return
            }

            completion(workouts)
        }

        healthStore.execute(query)
    }

    private func makeWorkoutSlothy(_ workout: HKWorkout) {
        // Query for workout's routes
        let routeType = HKSeriesType.workoutRoute()
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        let routeQuery = HKSampleQuery(sampleType: routeType, predicate: workoutPredicate, limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil) { _, results, error in
            guard let route = results?.first as? HKWorkoutRoute else {
                print("An error occured fetching the route: \(error?.localizedDescription ?? "Workout has no routes")")
                return
            }

            guard let version = route.metadata?[HKMetadataKeySyncVersion] as? NSNumber else {
                print("Route does not have a sync version for route \(route)")
                return
            }

            if version.intValue == 1 {
                self.makeWorkoutRouteSlothy(workout: workout, route: route)
            }
        }

        self.healthStore.execute(routeQuery)
    }

    private func makeWorkoutRouteSlothy(workout: HKWorkout, route: HKWorkoutRoute) {
        // Get all of the locations
        loadRouteLocations(route: route) { locations in
            // Slothify route
            let newLocations = self.slothifyRouteLocations(locations: locations)

            self.updateWorkoutRoute(workout: workout, route: route, newLocations: newLocations)
        }
    }

    private func loadRouteLocations(route: HKWorkoutRoute, completion: @escaping (_ locations: [CLLocation]) -> Void) {
        var locations = [CLLocation]()

        let locationQuery = HKWorkoutRouteQuery(route: route) { _, locationResults, done, error in
            guard let newLocations = locationResults else {
                print("Error occured while querying for locations: \(error?.localizedDescription ?? "")")
                return
            }
            locations += newLocations

            if done {
                completion(locations)
            }
        }

        healthStore.execute(locationQuery)
    }

    // Slothifying a workout route's locations will shift the locations left and right to form a moving spiral
    // around the original route
    private func slothifyRouteLocations(locations: [CLLocation]) -> [CLLocation] {
        var newLocations = [CLLocation]()

        let start = locations.first ?? CLLocation(latitude: 0, longitude: 0)
        newLocations.append(start)

        let radius = 0.0001

        var theta = 0.0
        for i in 1 ..< locations.count - 1 {
            theta += Double.pi / 8
            let dLatitude = sin(theta) * radius
            let dLongitude = cos(theta) * radius

            var coordinate = locations[i].coordinate
            coordinate.latitude += dLatitude
            coordinate.longitude += dLongitude
            let location = CLLocation(coordinate: coordinate,
                                      altitude: locations[i].altitude,
                                      horizontalAccuracy: locations[i].horizontalAccuracy,
                                      verticalAccuracy: locations[i].verticalAccuracy,
                                      course: locations[i].course,
                                      speed: locations[i].speed,
                                      timestamp: locations[i].timestamp)
            newLocations.append(location)
        }

        // Then jump to the last location
        if let lastLocation = locations.last {
            newLocations.append(lastLocation)
        }

        return newLocations
    }

    private func updateWorkoutRoute(workout: HKWorkout, route: HKWorkoutRoute, newLocations: [CLLocation]) {
        // Create a workout route builder
        let workoutRouteBuilder = HKWorkoutRouteBuilder(healthStore: self.healthStore, device: nil)

        // Insert updated route locations
        workoutRouteBuilder.insertRouteData(newLocations) { (success, error) in
            guard success else {
                print("An error occured while inserting route data: \(error?.localizedDescription ?? "Unknown")")
                return
            }

            guard let syncIdentifier = route.metadata?[HKMetadataKeySyncIdentifier] else {
                fatalError("Missing expected sync identifier on route")
            }

            // New metadata with the same sync identifier and a higher version
            var metadata = [String: Any]()
            metadata[HKMetadataKeySyncIdentifier] = syncIdentifier
            metadata[HKMetadataKeySyncVersion] = NSNumber(value: 2)

            // Finish the route with updated metadata
            workoutRouteBuilder.finishRoute(with: workout, metadata: metadata, completion: { workoutRoute, error in
                guard let route = workoutRoute else {
                    print("An error occured while finishing the new route: \(error?.localizedDescription ?? "Unknown")")
                    return
                }

                print("Workout route updated: \(route)")
            })
        }
    }

    // MARK: - IB Actions

    @IBAction private func slothifyWorkouts() {
        makeWorkoutsSlothy()
    }

    @IBAction private func activityTypePickerSelectedItemChanged(value: Int) {
        selectedActivityType = activityTypes[value]
    }

    @IBAction private func locationTypePickerSelectedItemChanged(value: Int) {
        selectedLocationType = locationTypes[value]
    }

    @IBAction private func didTapStartButton() {
        // Create workout configuration
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = selectedActivityType.type()
        workoutConfiguration.locationType = selectedLocationType.type()

        // Pass configuration to next interface controller
        WKInterfaceController.reloadRootPageControllers(withNames: ["WorkoutInterfaceController"],
                                                        contexts: [workoutConfiguration],
                                                        orientation: .vertical,
                                                        pageIndex: 0)
    }
}
