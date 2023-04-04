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
    static let height = 60
    var headerLabel: UILabel!
    var creditLabel: UILabel!
    
    init() {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 20,
                width: self.width,
                height: HeaderComponent.height
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
        //self.view.addSubview(self.creditLabel)
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
    
    @MainActor @objc func onPress(button: UIButton) {
        self.menuController?.openWindow(windowName: button.titleLabel?.text! ?? "")
    }
}

class MenuComponent {
    var view: UIView!
    var menuItems: [MenuItemComponent] = []
    let spacing = 10
    var menuController: MenuController?
    
    let menuItemNamesLoggedOut = [
        "Introduction",
        "Head2Heads",
        "Recent Races",
        "Login",
        "Sign Up"
    ]
    
    let menuItemNamesLoggedIn = [
        "Introduction",
        "Head2Heads",
        "Recent Races",
        "My Profile",
        "Logout"
    ]
    
 
    func setMenuItems(isLoggedin: Bool) {
        self.menuItems = []
        let names = (isLoggedin) ? self.menuItemNamesLoggedIn: self.menuItemNamesLoggedOut
        for menuItemName in names {
            let menuItemComponent = MenuItemComponent(text: menuItemName)
            menuItemComponent.menuController = self.menuController
            self.menuItems.append(menuItemComponent)
        }
    }
    

    func render(parentView: UIView, isLoggedin: Bool) {
        self.view = UIView()
        self.setMenuItems(isLoggedin: isLoggedin)
        self.menuItems.forEach { item in item.render(parentView: self.view) }
        let lastX = _expand_across(views: self.menuItems.map {$0.button}, spacing: 15)
        self.view.frame = CGRect(
            x: _get_center_x(width: Int(lastX)),
            y: HeaderComponent.height,
            width: Int(lastX),
            height: 30
        )
        parentView.addSubview(self.view)
    }
}


class MenuController {
    var menuComponent: MenuComponent!
    var viewController: ViewController!


    init (menuComponent: MenuComponent, viewController: ViewController) {
        self.viewController = viewController
        self.menuComponent = menuComponent
        self.menuComponent.menuController = self
    }
    
    @MainActor func openWindow(windowName: String) {
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
            case "Sign Up":
                self.viewController.userManager.signUpWindowComponent.render(parentView: parentView)
            case "Login":
                self.viewController.userManager.loginWindowComponent.render(parentView: parentView)
            case "Logout":
                self.viewController.userManager.userStateController.logoutUser()
            default:
                print("Unexpected window name")
        }
    }
}


class MenuManager {
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
    
    func render(isLoggedin: Bool) {
        self.headerComponent.render(parentView: self.viewController.view)
        self.menuComponent.render(parentView: self.viewController.view, isLoggedin: isLoggedin)
    }
}
