//
//  Introduction.swift
//  moto-ios
//
//  Created by Caspar Wylie on 21/03/2023.
//

import Foundation
import UIKit


class IntroductionWindowComponent: WindowComponent {
    var testLabel: UILabel!

   override init() {
        self.testLabel = _make_text(text: "This is the intro")
    }
    
    override func setWindowMeta() {
        self.title = "Introduction"
    }
    
    override func render(parentView: UIView) {
        super.render(parentView: parentView)
        self.view.addSubview(self.testLabel)
    }
}

class IntroductionManager {
    var parentView: UIView!
    var introductionWindowComponent: IntroductionWindowComponent!
    
    init (parentView: UIView) {
        self.parentView = parentView
        self.makeComponents()
    }
    
    func makeComponents() {
        self.introductionWindowComponent = IntroductionWindowComponent()
    }
    
    func render() {
        self.introductionWindowComponent.render(parentView: self.parentView)
    }
}
