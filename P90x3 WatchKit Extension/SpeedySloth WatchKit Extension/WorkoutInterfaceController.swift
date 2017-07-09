	/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Interface controller for the active workout screen.
*/

import WatchKit
import HealthKit

class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {

    // MARK: - Properties

    private let parentConnector = ParentConnector()
    private let healthStoreManager = HealthStoreManager()
    private var workoutSession: HKWorkoutSession!
    private var startDate: Date!
    private var endDate: Date!
    private var timer: Timer?

    // MARK: - IBOutlets

    @IBOutlet private var durationLabel: WKInterfaceLabel!
    @IBOutlet private var caloriesLabel: WKInterfaceLabel!
    @IBOutlet private var distanceLabel: WKInterfaceLabel!
    @IBOutlet private var pauseResumeButton: WKInterfaceButton!
    @IBOutlet private var markerLabel: WKInterfaceLabel!

    // MARK: - WKInterfaceController

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        guard let workoutConfiguration = context as? HKWorkoutConfiguration else {
            fatalError("context is not a HKWorkoutConfiguration")
        }

        // Create a workout session with the workout configuration
        do {
            workoutSession = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError(error.localizedDescription)
        }

        // Start a workout session
        workoutSession.delegate = self
        healthStoreManager.start(workoutSession)
    }

    // MARK: - IBActions

    @IBAction private func didTapPauseResumeButton() {
        self.requestPauseOrResume()
    }

    @IBAction private func didTapMarkerButton() {
        let markerEvent = HKWorkoutEvent(type: .marker, dateInterval: DateInterval(), metadata: nil)
        healthStoreManager.workoutEvents.append(markerEvent)
        notifyEvent(markerEvent)
    }

    @IBAction private func didTapStopButton() {
        healthStoreManager.end(workoutSession)
    }

    // MARK: - UI

    private func updateLabels() {
        caloriesLabel.setText(format(totalEnergyBurned: healthStoreManager.totalEnergyBurned))
        distanceLabel.setText(format(totalDistance: healthStoreManager.totalDistance))

        let events = healthStoreManager.workoutEvents
        let duration = computeDurationOfWorkout(withEvents: events, startDate: startDate, endDate: endDate)
        durationLabel.setText(format(duration: duration))
    }

    private func updateState() {
        switch workoutSession.state {
        case .notStarted:
            setTitle(NSLocalizedString("Starting", comment: "Title when the workout session is starting"))

        case .running:
            setTitle(WorkoutType(workoutSession.workoutConfiguration.activityType).displayString())
            parentConnector.send(state: "running")
            pauseResumeButton.setTitle(NSLocalizedString("Pause", comment: "Button label to pause the workout"))

        case .paused:
            setTitle(NSLocalizedString("Pause", comment: "Title when the workout session is paused"))
            parentConnector.send(state: "paused")
            pauseResumeButton.setTitle(NSLocalizedString("Resume", comment: "Button label to resume the workout"))

        case .ended:
            setTitle(NSLocalizedString("Ended", comment: "Title when the workout session has ended"))
            parentConnector.send(state: "ended")
        }
    }

    private func notifyEvent(_: HKWorkoutEvent) {
        WKInterfaceDevice.current().play(.notification)

        self.markerLabel.setAlpha(1)
        DispatchQueue.main.async {
            self.animate(withDuration: 1) {
                self.markerLabel.setAlpha(0)
            }
        }
    }

    // MARK: - Data Accumulation

    private func startAccumulatingData() {
        healthStoreManager.startWalkingRunningQuery(from: startDate) { quantitySamples in
            DispatchQueue.main.async {
                guard !self.isPaused() else { return }
                self.healthStoreManager.processWalkingRunningSamples(quantitySamples)
                self.updateLabels()
            }
        }
        healthStoreManager.startActiveEnergyBurnedQuery(from: startDate) { quantitySamples in
            DispatchQueue.main.async {
                guard !self.isPaused() else { return }
                self.healthStoreManager.processActiveEnergySamples(quantitySamples)
                self.updateLabels()
            }
        }

        if workoutSession.workoutConfiguration.locationType == .outdoor {
            healthStoreManager.startAccumulatingLocationData()
        }
    }

    private func stopAccumulatingData() {
        healthStoreManager.stopAccumulatingData()
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateLabels()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    // MARK: - HKWorkoutSessionDelegate

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workout session did fail with error: \(error)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        DispatchQueue.main.async {
            self.handleWorkoutSessionState(didChangeTo: toState, from: fromState)
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
        DispatchQueue.main.async {
            self.healthStoreManager.workoutEvents.append(event)
        }
    }

    private func handleWorkoutSessionState(didChangeTo toState: HKWorkoutSessionState,
                                           from fromState: HKWorkoutSessionState) {
        switch (fromState, toState) {
        case (.notStarted, .running):
            startDate = Date()
            startTimer()
            startAccumulatingData()

        case (_, .ended):
            stopAccumulatingData()
            endDate = Date()
            stopTimer()
            healthStoreManager.saveWorkout(withSession: workoutSession, from: startDate, to: endDate)

        default:
            break
        }

        updateLabels()
        updateState()
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
