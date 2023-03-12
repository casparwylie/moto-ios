//
//  Racing.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//
import UIKit
import Foundation

func _make_text (
    text: String,
    align: NSTextAlignment = .center,
    font: String = "ChakraPetch-Medium",
    size: CGFloat = 15
) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    label.textAlignment = align
    label.font = UIFont(name: font, size: size)
    label.text = text
    return label
}

class HeaderComponent {
    var view: UIView!
    let width = 300
    let height = 100
    var headerLabel: UILabel!
    var creditLabel: UILabel!
    
    init() {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 20,
                width: self.width,
                height: 0
            )
        )
        self.view.backgroundColor = .blue
    }
    
    func makeHeaderLabel() -> UILabel {
        self.headerLabel = _make_text(text: "What Bikes Win?", font: "Tourney", size: 30)
        self.headerLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: 30)
        self.headerLabel.backgroundColor = .green
        return self.headerLabel
    }
    
    func makeHeaderCreditLabel() -> UILabel {
        self.creditLabel = _make_text(text: "By Caspar Wylie", font: "Tourney")
        self.creditLabel.frame = CGRect(
            x: 0, y: Int(self.headerLabel.frame.height), width: self.width, height: 20
        )
        self.creditLabel.backgroundColor = .brown
        return self.creditLabel
    }
    
    func render(parentView: UIView) {
        self.view.addSubview(self.makeHeaderLabel())
        self.view.addSubview(self.makeHeaderCreditLabel())
        parentView.addSubview(self.view)
    }
}


class MenuComponent {
    var view: UIView!
    let width = global_width / 2;
    
    init() {
        self.view = UIView(
            frame: CGRect(
                x: 0,
                y: 70,
                width: global_width,
                height: 30
            )
        )
        self.view.backgroundColor = .purple;
    }
    func render(parentView: UIView) {
        parentView.addSubview(self.view)
    }
}

class ControlPanelComponent {
    var view: UIView!
    let width = global_width / 2;
    
    init() {
        self.view = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: global_width,
                height: 100
            )
        )
        self.view.backgroundColor = .red;
    }
    
    func render(parentView: UIView) {
        let header = HeaderComponent()
        let menu = MenuComponent()
        header.render(parentView: self.view)
        menu.render(parentView: self.view)
        parentView.addSubview(self.view)
    }
}
