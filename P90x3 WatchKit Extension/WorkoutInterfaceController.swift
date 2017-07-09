//
//  WorkoutInterfaceController.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/8/17.
//

import WatchKit
import Foundation
import HealthKit


class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    
    // MARK: - Properties
    
    private var workoutSession: HKWorkoutSession!
    private var startDate: Date!
    private var endDate: Date!
    private var timer: Timer?
    private let healthStore = HKHealthStore()
//    private let healthStoreManager = HealthStoreManager()
    
    // MARK: - IBOutlets
    
    @IBOutlet var durationLabel: WKInterfaceLabel!
    @IBOutlet var caloriesLabel: WKInterfaceLabel!
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    
    var currentWorkout: Workout!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        currentWorkout = context as! Workout
        setTitle(currentWorkout.name)
        setUpAndStartWorkout()
        
        // Configure interface objects here.
    }
    
    func setUpAndStartWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .indoor
        do {
            workoutSession = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError(error.localizedDescription)
        }
        workoutSession.delegate = self
        healthStore.start(workoutSession)
    }
    
    // MARK: - IBActions
    
    @IBAction func workoutEnded() {
        
    }
    
    // MARK: - HKWorkoutSessionDelegate
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workout session failed with error \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            if fromState == .notStarted {
//                startAccumulatingData()
            }
            break
        case .paused:
            break
        case .ended:
            break
        default:
            break
        }
        
        updateLabels()
        updateState()
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        print(event)
    }
    
    func startAccumulatingData() {
        startQuery(quantityTypeIdentifier: .heartRate)
        startQuery(quantityTypeIdentifier: .activeEnergyBurned)
    }
    
    func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { query, samples, deletedObjecs, queryAnchor, error in
            self.process(samples: samples, quantityTypeIdentifier: quantityTypeIdentifier)
        }
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: queryPredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        healthStore.execute(query)
    }
    
    func process(samples: [HKSample]?, quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        for sample in samples! {
            print(sample.sampleType)
        }
    }
    
    // MARK: - UI
    
    private func updateLabels() {
       // update labels
    }
    
    private func updateState() {
        switch workoutSession.state {
        case .notStarted:
            break
        case .running:
            break
        case .paused:
            break
        case .ended:
            break
            
        }
    }
    
//    private func handleWorkoutSessionState(didChangeTo toState: HKWorkoutSessionState,
//                                           from fromState: HKWorkoutSessionState) {
//        switch (fromState, toState) {
//        case (.notStarted, .running):
//            startDate = Date()
////            startTimer()
////            startAccumulatingData()
//
//        case (_, .ended):
////            stopAccumulatingData()
//            endDate = Date()
////            stopTimer()
////            healthStoreManager.saveWorkout(withSession: workoutSession, from: startDate, to: endDate)
//
//        default:
//            break
//        }
//
////        updateLabels()
////        updateState()
//    }
    
    
}
