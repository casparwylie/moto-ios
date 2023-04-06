//
//  GeneralComponents.swift
//  moto-ios
//
//  Created by Caspar Wylie on 21/03/2023.
//

import Foundation
import UIKit



class WindowComponent {
    var view: UIScrollView!
    var closeButton: UIButton!
    let closeSize = 25
    let titleWidth = global_width
    let titleHeight = 100
    var titleLabel: UILabel!
    var title: String = ""
    var titleColor: UIColor = .black
    var backgroundColor = UIColor(
        red: 0.00, green: 0.55, blue: 0.55, alpha: 1.00
    )
    
    let frame = CGRect(
        x: 0,
        y: 0,
        width: global_width,
        height: global_height
    )

    
    func setWindowMeta() {}
    
    func makeTitle() {
        self.titleLabel = _make_text(text: self.title, align: .center, font: "Tourney", size: 25, color: self.titleColor)
        self.titleLabel.frame = CGRect(
            x: _get_center_x(width: self.titleWidth),
            y: 5,
            width: self.titleWidth,
            height: self.titleHeight
        )
    }
    
    func makeClose() {
        self.closeButton = _make_button(text: "✕", color: .white, size: self.closeSize)
        self.closeButton.frame = CGRect(
            x: global_width - self.closeSize * 2,
            y: self.closeSize,
            width: self.closeSize,
            height: self.closeSize
        )
        self.closeButton.addTarget(
            self, action: #selector(self.onClosePress), for: .touchDown
        )
    }
    
    @objc func onClosePress(button: UIButton) {
        self.view.removeFromSuperview()
    }
    
    func render(parentView: UIView) {
        self.setWindowMeta()
        self.makeClose()
        self.makeTitle()
        self.view = UIScrollView(frame: self.frame)
        self.view.backgroundColor = self.backgroundColor
        self.view.addSubview(self.closeButton)
        self.view.addSubview(self.titleLabel)
        parentView.addSubview(self.view)
    }
}
