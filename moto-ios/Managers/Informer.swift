//
//  Informer.swift
//  moto-ios
//
//  Created by Caspar Wylie on 29/03/2023.
//

import Foundation
import UIKit


class InformerManager {
    
    var view: UILabel!
    var parentView: UIView!
    
    init(parentView: UIView) {
        self.parentView = parentView
    }
    
    func inform(message: String, mood: String = "good", duration: Int = 3) {
        switch(mood) {
            case "bad":
                self.view.backgroundColor = _RED
            case "good":
                self.view.backgroundColor = _GREEN
            default:
                self.view.backgroundColor = _DARK_BLUE
        }
        self.view.text = message.replacingOccurrences(of: "\n", with: "")
        _show(view: self.view)
        self.parentView.bringSubviewToFront(self.view)
        Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { (timer) in
            _hide(view: self.view)
        }
    }

    func render() {
        self.view = _make_text(text: "", align: .center, color: .white)
        self.view.frame = CGRect(x: 0, y: 0, width: global_width, height: 30)
        self.parentView.addSubview(self.view)
    }
}
