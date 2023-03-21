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
        super.init()
        self.testLabel = _make_text(text: "This is the intro")
    }
    
    override func setWindowMeta() {
        self.title = "Introduction"
    }
    
    func render(parentView: UIView) {
        self.view.addSubview(self.testLabel)
        parentView.addSubview(self.view)
    }
    
}

class Introduction {
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
