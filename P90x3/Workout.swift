//
//  Workout.swift
//  P90x3
//
//  Created by Naman Kedia on 7/2/17.
//

import Foundation

class Workout {
    let name: String
    let excercises: [String]
    
    init(name: String, excersises: [String]) {
        self.name = name
        self.excercises = excersises
    }
}

class Excercise {
    let name: String
    let excerciseType: type
    init(name: String, excerciseType: type) {
        self.name = name
        self.excerciseType = excerciseType
    }
    
    enum type {
        case thirtySeconds, tenTimes, tenTimesEccentrically
    }
    
}


