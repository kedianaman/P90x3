/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Manager for reading from and saving data into HealthKit
*/

import WatchKit
import HealthKit
import CoreLocation

class HealthStoreManager: NSObject, CLLocationManagerDelegate {

    // MARK: - Properties

    var workoutEvents = [HKWorkoutEvent]()
    var totalEnergyBurned: Double = 0
    var totalDistance: Double = 0

    private let healthStore = HKHealthStore()
    private var activeDataQueries = [HKQuery]()
    private var workoutRouteBuilder: HKWorkoutRouteBuilder!
    private var locationManager: CLLocationManager!

    // MARK: - Health Store Wrappers

    func start(_ workoutSession: HKWorkoutSession) {
        healthStore.start(workoutSession)
    }

    func end(_ workoutSession: HKWorkoutSession) {
        healthStore.end(workoutSession)
    }

    func pause(_ workoutSession: HKWorkoutSession) {
        healthStore.pause(workoutSession)
    }

    func resume(_ workoutSession: HKWorkoutSession) {
        healthStore.resumeWorkoutSession(workoutSession)
    }

    // MARK: - Data Accumulation

    func startWalkingRunningQuery(from startDate: Date, updateHandler: @escaping ([HKQuantitySample]) -> Void) {
        let typeIdentifier = HKQuantityTypeIdentifier.distanceWalkingRunning
        startQuery(ofType: typeIdentifier, from: startDate) { _, samples, _, _, error in
            guard let quantitySamples = samples as? [HKQuantitySample] else {
                print("Distance walking running query failed with error: \(String(describing: error))")
                return
            }
            updateHandler(quantitySamples)
        }
    }

    func startActiveEnergyBurnedQuery(from startDate: Date, updateHandler: @escaping ([HKQuantitySample]) -> Void) {
        let typeIdentifier = HKQuantityTypeIdentifier.activeEnergyBurned
        startQuery(ofType: typeIdentifier, from: startDate) { _, samples, _, _, error in
            guard let quantitySamples = samples as? [HKQuantitySample] else {
                print("Active energy burned query failed with error: \(String(describing: error))")
                return
            }
            updateHandler(quantitySamples)
        }
    }

    func startAccumulatingLocationData() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("User does not have location services enabled")
            return
        }

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()

        workoutRouteBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
    }

    func stopAccumulatingData() {
        for query in activeDataQueries {
            healthStore.stop(query)
        }
        activeDataQueries.removeAll()

        locationManager?.stopUpdatingLocation()
    }

    private func startQuery(ofType type: HKQuantityTypeIdentifier, from startDate: Date, handler: @escaping
        (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) {
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])

        let quantityType = HKObjectType.quantityType(forIdentifier: type)!

        let query = HKAnchoredObjectQuery(type: quantityType, predicate: queryPredicate, anchor: nil,
                                          limit: HKObjectQueryNoLimit, resultsHandler: handler)
        query.updateHandler = handler
        healthStore.execute(query)

        activeDataQueries.append(query)
    }

    // MARK: - Saving Data

    func saveWorkout(withSession workoutSession: HKWorkoutSession, from startDate: Date, to endDate: Date) {
        // Create and save a workout sample
        let configuration = workoutSession.workoutConfiguration
        var metadata = [String: Any]()
        metadata[HKMetadataKeyIndoorWorkout] = (configuration.locationType == .indoor)

        let workout = HKWorkout(activityType: configuration.activityType,
                                start: startDate,
                                end: endDate,
                                workoutEvents: workoutEvents,
                                totalEnergyBurned: totalEnergyBurnedQuantity(),
                                totalDistance: totalDistanceQuantity(),
                                metadata: metadata)

        healthStore.save(workout) { success, _ in
            if success {
                self.addSamples(toWorkout: workout, from: startDate, to: endDate)
            }
        }
    }

    private func addSamples(toWorkout workout: HKWorkout, from startDate: Date, to endDate: Date) {
        // Create energy and distance samples
        let totalEnergyBurnedSample = HKQuantitySample(type: HKQuantityType.activeEnergyBurned(),
                                                       quantity: totalEnergyBurnedQuantity(),
                                                       start: startDate,
                                                       end: endDate)

        let totalDistanceSample = HKQuantitySample(type: HKQuantityType.distanceWalkingRunning(),
                                                   quantity: totalDistanceQuantity(),
                                                   start: startDate,
                                                   end: endDate)

        // Add samples to workout
        healthStore.add([totalEnergyBurnedSample, totalDistanceSample], to: workout) { (success: Bool, error: Error?) in
            guard success else {
                print("Adding workout subsamples failed with error: \(String(describing: error))")
                return
            }

            // Samples have been added
            DispatchQueue.main.async {
                WKInterfaceController.reloadRootPageControllers(withNames: ["SummaryInterfaceController"],
                                                                contexts: [workout],
                                                                orientation: .vertical,
                                                                pageIndex: 0)
            }
        }

        // Finish the route with a sync identifier so we can easily update the route later
        var metadata = [String: Any]()
        metadata[HKMetadataKeySyncIdentifier] = UUID().uuidString
        metadata[HKMetadataKeySyncVersion] = NSNumber(value: 1)

        workoutRouteBuilder?.finishRoute(with: workout, metadata: metadata) { (workoutRoute, error) in
            if workoutRoute == nil {
                print("Finishing route failed with error: \(String(describing: error))")
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= kCLLocationAccuracyNearestTenMeters
        }

        guard !filteredLocations.isEmpty else { return }

        workoutRouteBuilder.insertRouteData(filteredLocations) { (success, error) in
            if !success {
                print("inserting route data failed with error: \(String(describing: error))")
            }
        }
    }

    // MARK: - Convenience

    func processWalkingRunningSamples(_ samples: [HKQuantitySample]) {
        totalDistance = samples.reduce(totalDistance) { (total, sample) in
            total + sample.quantity.doubleValue(for: .meter())
        }
    }

    func processActiveEnergySamples(_ samples: [HKQuantitySample]) {
        totalEnergyBurned = samples.reduce(totalEnergyBurned) { (total, sample) in
            total + sample.quantity.doubleValue(for: .kilocalorie())
        }
    }

    private func totalEnergyBurnedQuantity() -> HKQuantity {
        return HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: totalEnergyBurned)
    }

    private func totalDistanceQuantity() -> HKQuantity {
        return HKQuantity(unit: HKUnit.meter(), doubleValue: totalDistance)
    }
}
