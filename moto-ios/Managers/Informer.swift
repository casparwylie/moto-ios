//
//  Informer.swift
//  moto-ios
//
//  Created by Caspar Wylie on 29/03/2023.
//

import Foundation
import UIKit


class InformerComponent {
    var view: UILabel!
    
    func render(parentView: UIView) {
        self.view = Label().make(text: "", align: .center, color: .white)
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: uiDef().ROW_HEIGHT)
        parentView.addSubview(self.view)
    }
    
    func setText(message: String, mood: String = "good") {
        switch(mood) {
            case "bad":
                self.view.backgroundColor = _RED
            case "good":
                self.view.backgroundColor = _GREEN
            default:
                self.view.backgroundColor = _DARK_BLUE
        }
        self.view.text = message.replacingOccurrences(of: "\n", with: "")
    }
}


class InformerController {
    
    var informerComponent: InformerComponent!
    var parentView: UIView!
    
    init(informerComponent: InformerComponent, parentView: UIView) {
        self.parentView = parentView
        self.informerComponent = informerComponent
    }
    
    func inform(message: String, mood: String = "good", duration: Int = 3) {
        self.informerComponent.setText(message: message, mood: mood)
        show(view: self.informerComponent.view)
        self.parentView.bringSubviewToFront(self.informerComponent.view)
        Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { (timer) in
            hide(view: self.informerComponent.view)
        }
    }
}


class InformerManager {
    
    var parentView: UIView!
    var informerComponent: InformerComponent!
    var informerController: InformerController!

    
    init(parentView: UIView) {
        self.parentView = parentView
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents() {
        self.informerComponent = InformerComponent()
    }
    
    func makeControllers() {
        self.informerController = InformerController(
            informerComponent: self.informerComponent,
            parentView: parentView
        )
    }
    
    func render() {
        self.informerComponent.render(parentView: self.parentView)
    }
}
