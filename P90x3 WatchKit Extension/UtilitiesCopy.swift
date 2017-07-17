/*
 See LICENSE.txt for this sample’s licensing information.
 
 Abstract:
 Utilites for workout management and string formatting.
 */

import Foundation
import HealthKit

// MARK: - Workout Type

enum WorkoutType {
    case walking
    case running
    case hiking
    
    init(_ workoutActivityType: HKWorkoutActivityType) {
        switch workoutActivityType {
        case .walking:
            self = .walking
        case .running:
            self = .running
        case .hiking:
            self = .hiking
        default:
            fatalError("unsupported HKWorkoutActivityType: \(workoutActivityType)")
        }
    }
    
    func type() -> HKWorkoutActivityType {
        switch self {
        case .walking:
            return .walking
        case .running:
            return .running
        case .hiking:
            return .hiking
        }
    }
    
    func displayString() -> String {
        switch self {
        case .walking:
            return NSLocalizedString("Walking", comment:"Workout activity type for walking")
        case .running:
            return NSLocalizedString("Running", comment:"Workout activity type for running")
        case .hiking:
            return NSLocalizedString("Hiking", comment:"Workout activity type for hiking")
        }
    }
}

// MARK: - Location Type

enum LocationType {
    case indoor
    case outdoor
    
    init(_ workoutLocationType: HKWorkoutSessionLocationType) {
        switch workoutLocationType {
        case .indoor:
            self = .indoor
        case .outdoor:
            self = .outdoor
        default:
            fatalError("unsupported HKWorkoutSessionLocationType: \(workoutLocationType)")
        }
    }
    
    func type() -> HKWorkoutSessionLocationType {
        switch self {
        case .indoor:
            return .indoor
        case .outdoor:
            return .outdoor
            
        }
    }
    
    func displayString() -> String {
        switch self {
        case .indoor:
            return NSLocalizedString("Indoor", comment:"Workout location type for indoor")
        case .outdoor:
            return NSLocalizedString("Outdoor", comment:"Workout location type for outdoor")
        }
    }
}

// MARK: - Total Energy Burned

func format(totalEnergyBurned: Double) -> String {
    let caloriesString = NSLocalizedString("Calories", comment: "Unit display for Calories")
    let formatString = NSLocalizedString("VALUE_%@_UNIT_%@", comment: "Label for numeric value with unit")
    return String(format: formatString, totalEnergyBurned, caloriesString)
}

func format(totalEnergyBurned: HKQuantity?) -> String {
    return format(totalEnergyBurned: totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
}



// MARK: - Total Distance

func format(totalDistance: Double) -> String {
    let metersString = NSLocalizedString("Meters", comment: "Unit display for Calories")
    let formatString = NSLocalizedString("VALUE_%@_UNIT_%@", comment: "Label for numeric value with unit")
    return String(format: formatString, totalDistance, metersString)
}

func format(totalDistance: HKQuantity?) -> String {
    return format(totalDistance: totalDistance?.doubleValue(for: .meter()) ?? 0)
}

// MARK: - Duration

func computeDurationOfWorkout(withEvents workoutEvents: [HKWorkoutEvent]?,
                              startDate: Date?, endDate: Date?) -> TimeInterval {
    var duration = 0.0
    
    guard var lastDate = startDate else {
        return duration
    }
    
    let events = (workoutEvents ?? []).filter { event in
        return event.type == .pause || event.type == .resume
    }
    
    for event in events {
        switch event.type {
        case .pause:
            duration += event.dateInterval.start.timeIntervalSince(lastDate)
            
        case .resume:
            lastDate = event.dateInterval.start
            
        default:
            continue
        }
    }
    
    if events.last?.type != .pause {
        let end = endDate ?? Date()
        duration += end.timeIntervalSince(lastDate)
    }
    
    return duration
}

func format(duration: TimeInterval) -> String {
    let durationFormatter = DateComponentsFormatter()
    durationFormatter.unitsStyle = .positional
    durationFormatter.allowedUnits = [.second, .minute, .hour]
    durationFormatter.zeroFormattingBehavior = .pad
    
    if let string = durationFormatter.string(from: duration) {
        return string
    } else {
        return ""
    }
}

