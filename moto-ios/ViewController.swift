//
//  ViewController.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import UIKit

var global_width = Int(UIScreen.main.bounds.size.width)
var global_height = Int(UIScreen.main.bounds.size.height)

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.rotated),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        self.renderUI()
    }

    @objc func rotated() {
        global_width = Int(UIScreen.main.bounds.size.width)
        global_height = Int(UIScreen.main.bounds.size.height)
        self.renderUI()
    }
    
    func renderUI() {
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
        let controlPanel = ControlPanelComponent()
        controlPanel.render(parentView: self.view)
    }

}

