//
//  ExcerciseWkInterfaceController.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/4/17.
//

import WatchKit
import Foundation


class ExcerciseInterfaceController: WKInterfaceController {

    @IBOutlet var workoutTitleLabel: WKInterfaceLabel!
    @IBOutlet var workoutTypeLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let exercise = context as! String
        workoutTitleLabel.setText(exercise)
    }

}
