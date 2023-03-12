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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (global_width < global_height) {
            let fwidth = global_width
            global_width = global_height
            global_height = fwidth
        }
        print(global_width)
        print(global_height)
        self.renderUI()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }

    func renderUI() {
        self.view.backgroundColor = .white
        let controlPanel = ControlPanelComponent()
        controlPanel.render(parentView: self.view)
    }

}

