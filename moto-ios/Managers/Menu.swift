//
//  Menu.swift
//  moto-ios
//
//  Created by Caspar Wylie on 21/03/2023.
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
        self.makeHeaderLabel()
        self.makeHeaderCreditLabel()
    }
    
    func makeHeaderLabel() {
        self.headerLabel = _make_text(text: "What Bikes Win?", font: "Tourney", size: 30)
        self.headerLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: 30)
    }
    
    func makeHeaderCreditLabel() {
        self.creditLabel = _make_text(text: "By Caspar Wylie", font: "Tourney")
        self.creditLabel.frame = CGRect(
            x: 0, y: Int(self.headerLabel.frame.height), width: self.width, height: 20
        )
    }
    
    func render(parentView: UIView) {
        self.view.addSubview(self.headerLabel)
        self.view.addSubview(self.creditLabel)
        parentView.addSubview(self.view)
    }
}


class MenuItemComponent {
    var text: String!
    var button: UIButton!
    var menuController: MenuController?
    
    init(text: String) {
        self.text = text
        self.button = _make_button(text: self.text)
        self.button.frame.size = self.button.intrinsicContentSize
        self.button.addBottomBorderWithColor(color: .black, width: 1)
        self.button.addTarget(
            self, action: #selector(self.onPress), for: .touchDown
        )
    }
    
    func render(parentView: UIView) {
        parentView.addSubview(self.button)
    }
    
    @objc func onPress(button: UIButton) {
        self.menuController?.openWindow(windowName: button.titleLabel?.text! ?? "")
    }
}

class MenuComponent {
    var view: UIView!
    var menuItems: [MenuItemComponent] = []
    let spacing = 10
    var menuController: MenuController?
    
    init() {
        self.view = UIView()
    }
    
    func setMenuItems(menuItemNames: [String]) {
        for menuItemName in menuItemNames {
            let menuItemComponent = MenuItemComponent(text: menuItemName)
            menuItemComponent.menuController = self.menuController
            self.menuItems.append(menuItemComponent)
        }
    }

    func render(parentView: UIView) {
        var totalWidth = 0
        for item in self.menuItems {
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


class MenuController {
    var menuComponent: MenuComponent!
    var viewController: ViewController!
    
    let menuItems = [
        "Introduction",
        "Head2Heads",
        "Recent Races",
        "Login",
        "Sign Up"
    ]

    init (menuComponent: MenuComponent, viewController: ViewController) {
        self.viewController = viewController
        self.menuComponent = menuComponent
        self.menuComponent.menuController = self
        self.menuComponent.setMenuItems(menuItemNames: self.menuItems)
    }
    
    func openWindow(windowName: String) {
        let parentView = self.viewController.view!
        switch(windowName) {
            case "Introduction":
                self.viewController.introductionManager.render()
            case "Head2Heads":
                self.viewController.insightManager.h2hWindowComponent.render(
                    parentView: parentView)
            case "Recent Races":
                self.viewController.insightManager.recentRacesWindowComponent.render(
                    parentView: parentView)
            default:
                print("Unexpected window name")
        }
    }
}


class Menu {
    var viewController: ViewController!
    var headerComponent: HeaderComponent!
    var menuComponent: MenuComponent!
    var menuController: MenuController!

    
    init(viewController: ViewController) {
        self.viewController = viewController
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents () {
        self.headerComponent = HeaderComponent()
        self.menuComponent = MenuComponent()
    }
    
    func makeControllers() {
        self.menuController = MenuController(menuComponent: self.menuComponent, viewController: self.viewController)
    }
    
    func render() {
        self.headerComponent.render(parentView: self.viewController.view)
        self.menuComponent.render(parentView: self.viewController.view)
    }
}
