//
//  WorkoutViewController.swift
//  P90x3
//
//  Created by Naman Kedia on 7/17/17.
//

import UIKit
import HealthKit
import WatchConnectivity

class WorkoutViewController: UIViewController, WCSessionDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
  
    @IBOutlet weak var statusLabel: UILabel!

    // MARK: - Properties
    var workout: Workout?
    var workoutConfiguration: HKWorkoutConfiguration!
    private let healthStore = HKHealthStore()
    private var wcSessionActivationCompletion: ((WCSession) -> Void)?
    private var watchConnectivitySession: WCSession?
    private var stateDate: Date?
    
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .indoor
        self.navigationItem.title = workout!.name
        startWatchApp()
    }
    
    // MARK: - Convenience
    private func startWatchApp() {
        guard let workoutConfiguration = workoutConfiguration else { return }
        
        getActiveWCSession { wcSession in
            if wcSession.activationState == .activated && wcSession.isWatchAppInstalled {
                self.healthStore.startWatchApp(with: workoutConfiguration) { (success, error) in
                    if !success {
                        print("starting watch app failed with error: \(String(describing: error))")
                    }
                }
            }
        }
    }
    
    private func getActiveWCSession(completion: @escaping (WCSession) -> Void) {
        guard WCSession.isSupported() else {
            // ... Alert the user that their iOS device does not support watch connectivity
            fatalError("watch connectivity session not supported")
        }
        
        let wcSession = WCSession.default
        wcSession.delegate = self
        
        switch wcSession.activationState {
        case .activated:
            completion(wcSession)
        case .inactive, .notActivated:
            wcSession.activate()
            wcSessionActivationCompletion = completion
        }
    }
    
    private func updateSessionState(_ state: String) {
        if state == "ended" {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        } else {
            statusLabel.text = state
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated, let activationCompletion = wcSessionActivationCompletion {
            activationCompletion(session)
            wcSessionActivationCompletion = nil
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let state = message["State"] as? String {
            DispatchQueue.main.async {
                self.updateSessionState(state)
            }
        }
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    // MARK: - Table View Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout!.excercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExcerciseCellIdentifier", for: indexPath)
        cell.textLabel?.text = workout!.excercises[indexPath.row]
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
    

}
