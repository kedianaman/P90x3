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
    
    private let parentConnector = ParentConnector()
    private let healthStoreManager = HealthStoreManager()
    private var workoutSession: HKWorkoutSession!
    private var startDate: Date!
    private var endDate: Date!
    private var timer: Timer?
    
    
    var workoutEvents = [HKWorkoutEvent]()
    
    
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
        healthStoreManager.start(workoutSession)
    }
    
    // MARK: - IBActions
    
    @IBAction func workoutEnded() {
        

        healthStoreManager.end(workoutSession)
    }
    
    // MARK: - HKWorkoutSessionDelegate
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workout session failed with error \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            if fromState == .notStarted {
                print("Workout started")
                startTimer()
                startDate = Date()
                startAccumulatingData()
            }
            break
        case .paused:
            break
        case .ended:
            stopAccumulatingData()
            endDate = Date()
            stopTimer()
            healthStoreManager.saveWorkout(withSession: workoutSession, from: startDate, to: endDate, workoutName: currentWorkout.name)
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
        healthStoreManager.startActiveEnergyBurnedQuery(from: startDate) { quantitySamples in
            DispatchQueue.main.async {
                guard !self.isPaused() else { return }
                self.healthStoreManager.processActiveEnergySamples(quantitySamples)
                self.updateLabels()
            }
        }
        healthStoreManager.startHeartRateQuery(from: startDate) { quantitySamples in
            DispatchQueue.main.async {
                guard !self.isPaused() else { return }
                self.healthStoreManager.processHeartRateSamples(quantitySamples)
                self.updateLabels()
            }
        }
    }
    
    func stopAccumulatingData() {
        healthStoreManager.stopAccumulatingData()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        // Not working. Fix
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateLabels()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    // MARK: - UI
    
    private func updateLabels() {
        caloriesLabel.setText("\(Int(healthStoreManager.totalEnergyBurned)) CAL")
        heartRateLabel.setText("\(Int(healthStoreManager.currentHeartRate)) BPM")
        
        let events = healthStoreManager.workoutEvents
        let duration = computeDurationOfWorkout(withEvents: events, startDate: startDate, endDate: endDate)
        durationLabel.setText(format(duration: duration))
    }
    
    private func updateState() {
        switch workoutSession.state {
        case .notStarted:
//            setTitle(NSLocalizedString("Starting", comment: "Title when the workout session is starting"))
            print("Starting")
            
        case .running:
//            setTitle(WorkoutType(workoutSession.workoutConfiguration.activityType).displayString())
            parentConnector.send(state: "running")
            
        case .paused:
//            setTitle(NSLocalizedString("Pause", comment: "Title when the workout session is paused"))
            parentConnector.send(state: "paused")
            
        case .ended:
//            setTitle(NSLocalizedString("Ended", comment: "Title when the workout session has ended"))
            parentConnector.send(state: "ended")
        }
    }
    
    
    // MARK: - Convenience
    
    private func isPaused() -> Bool {
        return (workoutSession.state == .paused)
    }
    
    private func requestPauseOrResume() {
        if isPaused() {
            healthStoreManager.resume(workoutSession)
        } else {
            healthStoreManager.pause(workoutSession)
        }
    }
    
}
