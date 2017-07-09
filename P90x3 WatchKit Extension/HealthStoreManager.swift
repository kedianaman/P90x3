//
//  HealthStoreManager.swift
//  P90x3
//
//  Created by Naman Kedia on 7/8/17.
//

import Foundation
import HealthKit
import CoreLocation

class HealthStoreManager: NSObject {
    // MARK: - Properties
    
    var workoutEvents = [HKWorkoutEvent]()
    var totalEnergyBurned: Double = 0
    var totalDistance: Double = 0
    
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
    
    

}
