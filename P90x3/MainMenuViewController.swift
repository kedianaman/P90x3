//
//  ViewController.swift
//  P90x3
//
//  Created by Naman Kedia on 7/1/17.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var ringView: RingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ringView.animate()
    }


}

