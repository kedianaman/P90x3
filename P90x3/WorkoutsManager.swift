//
//  WorkoutsManager.swift
//  P90x3
//
//  Created by Naman Kedia on 7/2/17.
//

import Foundation

class WorkoutManager {
    
    private var workouts = [Workout]()
    
    private let workoutNames = ["Eccentric Upper", "Incinerator"]
    private let excercisesForWorkout =
        ["Eccentric Upper": [
            "Standard Push Up",
            "Standard Pull Up",
            "Military Press",
            "Military Push Ups",
            "Chin Ups",
            "Deep Swimmers Press",
            "Fly Push Ups",
            "V Pull Ups",
            "Upright Hammer Pull",
            "Staggered Push Ups",
            "Rocket Launcher Row",
            "Lateral/Anterior Raise",
            "Plyo Push Ups",
            "Vaulter Pull Ups",
            "Pterodactyl Flys",
            "Rocket Launcher Kick Back",
            "Flip Flop Combo",
            "Tricep Skyfers",
            "Kneeling Preacher Curl",
            "Burnout"],
         "Incinerator": [
            "Renegade Row",
            "Pull Ups",
            "Floor Flys",
            "Push Ups",
            "Rocket Launcher Row",
            "Chin Ups",
            "A Press",
            "Military Push Ups",
            "Monkey Pump",
            "Pike Press",
            "Pterodactyl Flys",
            "Flipper",
            "Popeye Hammer Curls",
            "Kneeler Curls",
            "Hail To The Cheif",
            "Skyfers",
            "Arm and Hammer",
            "Rocket Launcher Kickbacks",
            "Burnout",]]
    
    init() {
        for workoutName in workoutNames {
            workouts.append(Workout(name: workoutName, excersises: excercisesForWorkout[workoutName]!))
        }
    }
    
    func workoutAtIndex(index: Int) -> Workout {
        return workouts[index]
    }
    
    func numberOfWorkouts() -> Int {
        return workouts.count
        
    }
    
    func allWorkouts() -> [Workout] {
        return self.workouts
    }
}


