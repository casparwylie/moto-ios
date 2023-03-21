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
    let closeSize = 20
    let titleWidth = global_width
    var titleLabel: UILabel!
    var title: String = ""
    var titleColor: UIColor = .black
    var backgroundColor = UIColor(
        red: 0.00, green: 0.55, blue: 0.55, alpha: 1.00
    )

    
    init() {
        self.view = UIScrollView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: global_width,
                height: global_height
            )
        )
        
        self.setWindowMeta()
        self.view.backgroundColor = self.backgroundColor
        self.makeClose()
        self.makeTitle()
        self.prerender()
    }
    
    func setWindowMeta() {}
    
    func makeTitle() {
        self.titleLabel = _make_text(text: self.title, align: .center, font: "Tourney", size: 25, color: self.titleColor)
        self.titleLabel.frame = CGRect(x: _get_center_x(width: self.titleWidth), y: 5, width: self.titleWidth, height: 30)
    }
    
    func makeClose() {
        self.closeButton = _make_button(text: "x", color: .white)
        self.closeButton.frame = CGRect(x: global_width - closeSize, y: 5, width: closeSize, height: closeSize)
        self.closeButton.addTarget(
            self, action: #selector(self.onClosePress), for: .touchDown
        )
    }
    
    @objc func onClosePress(button: UIButton) {
        self.view.removeFromSuperview()
    }
    
    func prerender() {
        self.view.addSubview(self.closeButton)
        self.view.addSubview(self.titleLabel)
    }
}
