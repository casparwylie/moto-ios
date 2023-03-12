//
//  Racing.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//
import UIKit
import Foundation



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
    }
    
    func makeHeaderLabel() -> UILabel {
        self.headerLabel = _make_text(text: "What Bikes Win?", font: "Tourney", size: 30)
        self.headerLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: 30)
        return self.headerLabel
    }
    
    func makeHeaderCreditLabel() -> UILabel {
        self.creditLabel = _make_text(text: "By Caspar Wylie", font: "Tourney")
        self.creditLabel.frame = CGRect(
            x: 0, y: Int(self.headerLabel.frame.height), width: self.width, height: 20
        )
        return self.creditLabel
    }
    
    func render(parentView: UIView) {
        self.view.addSubview(self.makeHeaderLabel())
        self.view.addSubview(self.makeHeaderCreditLabel())
        parentView.addSubview(self.view)
    }
}


class MenuItemComponent {
    var text: String!
    var button: UIButton!
    
    init(text: String) {
        self.text = text
        self.button = _make_button(text: self.text)
        self.button.frame.size = self.button.intrinsicContentSize
        self.button.addBottomBorderWithColor(color: .black, width: 1)
        
    }
    
    func render(parentView: UIView) {
        parentView.addSubview(self.button)
    }
}

class MenuComponent {
    var view: UIView!
    var menuItems: [MenuItemComponent] = []
    let spacing = 10
    
    init() {
        self.view = UIView()
    }
    
    func makeMenuItems() -> [MenuItemComponent] {
        return [
            MenuItemComponent(text: "Introduction"),
            MenuItemComponent(text: "Head2Heads"),
            MenuItemComponent(text: "Recent Races"),
            MenuItemComponent(text: "Login"),
            MenuItemComponent(text: "Sign Up"),
        ]
    }
    func render(parentView: UIView) {
        var totalWidth = 0
        for item in self.makeMenuItems() {
            item.button.frame = CGRect(
                x: CGFloat(totalWidth),
                y: 0,
                width: item.button.frame.size.width,
                height: item.button.frame.size.height)
            item.render(parentView: self.view)
            totalWidth += Int(item.button.frame.width) + self.spacing
        }
        self.view.frame = CGRect(
            x: _get_center_x(width: totalWidth),
            y: 70,
            width: totalWidth,
            height: 30
        )
        parentView.addSubview(self.view)
    }
}

class ControlPanelComponent {
    var view: UIView!
    let width = global_width
    
    init() {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 0,
                width: self.width,
                height: 100
            )
        )
        self.view.backgroundColor = .red
    }
    
    func render(parentView: UIView) {
        let header = HeaderComponent()
        let menu = MenuComponent()
        header.render(parentView: self.view)
        menu.render(parentView: self.view)
        parentView.addSubview(self.view)
    }
}
