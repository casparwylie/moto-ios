//
//  ViewController.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import UIKit
import SwiftUI


var global_width = Int(UIScreen.main.bounds.size.width)
var global_height = Int(UIScreen.main.bounds.size.height)

func switchRenderOrientation() {
    if (global_width < global_height) {
        let fwidth = global_width
        global_width = global_height
        global_height = fwidth
    }
}

class ViewController: UIViewController {
    
    var racingContext: Racing!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        let racingApiClient = RacingApiClient(
            base_url: "https://whatbikeswin.com/api/racing")
        self.racingContext = Racing(
            apiClient: racingApiClient, view: self.view)
        self.racingContext.renderUI()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    func initialSetup() {
        // Ensure landscape orientation
        switchRenderOrientation()
        
        // Set basic UI
        self.view.backgroundColor = .white
        
        // Setup Keyboard dismissing
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }


}

