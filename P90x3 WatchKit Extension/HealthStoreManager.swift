//
//  HealthStoreManager.swift
//  P90x3
//
//  Created by Naman Kedia on 7/8/17.
//

import Foundation
import HealthKit
import CoreLocation
import WatchKit

class HealthStoreManager: NSObject {
    // MARK: - Properties
    
    var workoutEvents = [HKWorkoutEvent]()
    var totalEnergyBurned: Double = 0
    var totalDistance: Double = 0
    var currentHeartRate: Double = 0
    var totalHeartRate: Double = 0
    var heartRateCount: Int = 0
    
    private let healthStore = HKHealthStore()
    private var activeDataQueries = [HKQuery]()
    
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
    
    func startHeartRateQuery(from startDate: Date, updateHandler: @escaping ([HKQuantitySample]) -> Void) {
        let typeIdentifier = HKQuantityTypeIdentifier.heartRate
        startQuery(ofType: typeIdentifier, from: startDate) { _, samples, _, _, error in
            guard let quantitySamples = samples as? [HKQuantitySample] else {
                print("Heartrate query failed with error: \(String(describing: error))")
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
    
    func stopAccumulatingData() {
        for query in activeDataQueries {
            healthStore.stop(query)
        }
        activeDataQueries.removeAll()
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
    
    func saveWorkout(withSession workoutSession: HKWorkoutSession, from startDate: Date, to endDate: Date, workoutName: String) {
        // Create and save a workout sample
        let configuration = workoutSession.workoutConfiguration
        var metadata = [String: Any]()
        metadata[HKMetadataKeyIndoorWorkout] = (configuration.locationType == .indoor)
        metadata[HKMetadataKeyWorkoutBrandName] = workoutName
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
        
        let heartRateSample = HKQuantitySample(type: HKQuantityType.heartRate(), quantity: averageHeartRateQuantity(), start: startDate, end: endDate)
        
        print("Added samples. Average heartrate: \(averageHeartRateQuantity()).")
//        let totalDistanceSample = HKQuantitySample(type: HKQuantityType.distanceWalkingRunning(),
//                                                   quantity: totalDistanceQuantity(),
//                                                   start: startDate,
//                                                   end: endDate)
        
        // Add samples to workout
        healthStore.add([totalEnergyBurnedSample, heartRateSample], to: workout) { (success: Bool, error: Error?) in
            guard success else {
                print("Adding workout subsamples failed with error: \(String(describing: error))")
                return
            }
            
            // Samples have been added
            DispatchQueue.main.async {
                WKInterfaceController.reloadRootControllers(withNames: ["SummaryInterfaceControllerIdentifier"], contexts: [workout])
            }
        }
        
    }
    
    // MARK: - Convenience
    
    func processWalkingRunningSamples(_ samples: [HKQuantitySample]) {
        for sample in samples {
            print(sample.quantity)
        }
        totalDistance = samples.reduce(totalDistance) { (total, sample) in
            total + sample.quantity.doubleValue(for: .meter())
        }
    }
    
    func processActiveEnergySamples(_ samples: [HKQuantitySample]) {
        for sample in samples {
            print(sample.quantity)
        }
        totalEnergyBurned = samples.reduce(totalEnergyBurned) { (total, sample) in
            total + sample.quantity.doubleValue(for: .kilocalorie())
        }
    }
    
    func processHeartRateSamples(_ samples: [HKQuantitySample]) {
        for sample in samples {
            print(sample.quantity)
            currentHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        }
        if currentHeartRate != 0.0 {
            totalHeartRate = totalHeartRate + currentHeartRate
            heartRateCount = heartRateCount + 1
        }
        
    }
    
    private func totalEnergyBurnedQuantity() -> HKQuantity {
        return HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: totalEnergyBurned)
    }
    
    private func totalDistanceQuantity() -> HKQuantity {
        return HKQuantity(unit: HKUnit.meter(), doubleValue: totalDistance)
    }
    
    private func averageHeartRateQuantity() -> HKQuantity {
        return HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: totalHeartRate/Double(heartRateCount))
    }
}


extension HKQuantityType {
    static func distanceWalkingRunning() -> HKQuantityType {
        return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
    }
    
    static func distanceCycling() -> HKQuantityType {
        return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!
    }
    
    static func activeEnergyBurned() -> HKQuantityType {
        return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
    }
    
    static func heartRate() -> HKQuantityType {
        return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    }
}

