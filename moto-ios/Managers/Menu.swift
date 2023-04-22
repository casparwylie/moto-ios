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
    let headerLabelSize = uiDef().HEADER_FONT_SIZE
    let creditLabelSize = uiDef().FONT_SIZE
    static let height = uiDef().HEADER_FONT_SIZE + uiDef().FONT_SIZE
    var headerLabel: UILabel!
    var creditLabel: UILabel!
    
    var menuController: MenuController?

    func makeHeaderLabel() {
        self.headerLabel = Label().make(
            text: "What Bikes Win?", font: "Tourney", size: CGFloat(self.headerLabelSize)
        )
        self.headerLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: self.headerLabelSize)
    }
    
    func makeHeaderCreditLabel() {
        var text = ""
        if let username = self.menuController?.userStateController?.currentUser?.username {
            text = "Welcome, \(username)"
        }
        self.creditLabel = Label().make(text: text, font: "Tourney", size: CGFloat(self.creditLabelSize), color: _LIGHT_GREY)
        self.creditLabel.frame = CGRect(
            x: 0, y: Int(self.headerLabel.frame.height), width: self.width, height: self.creditLabelSize
        )
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: getCenterX(width: self.width),
                y: 20,
                width: self.width,
                height: HeaderComponent.height
            )
        )
        self.makeHeaderLabel()
        self.makeHeaderCreditLabel()
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
        self.button = Button().make(text: self.text)
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
    static let height = uiDef().ROW_HEIGHT
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
        "Me",
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
    

    func render(parentView: UIView) {
        self.view = UIView()
        let isLoggedin = (self.menuController?.userStateController?.isLoggedin())!
        self.setMenuItems(isLoggedin: isLoggedin)
        self.menuItems.forEach { item in item.render(parentView: self.view) }
        let lastX = expandAcross(views: self.menuItems.map {$0.button}, spacing: 15)
        self.view.frame = CGRect(
            x: getCenterX(width: Int(lastX)),
            y: HeaderComponent.height + uiDef().ROW_HEIGHT / 2,
            width: Int(lastX),
            height: MenuComponent.height
        )
        parentView.addSubview(self.view)
    }
}


class MenuController {
    var menuComponent: MenuComponent!
    var headerComponent: HeaderComponent!
    var viewController: ViewController!
    
    var userStateController: UserStateController?


    init (menuComponent: MenuComponent, headerComponent: HeaderComponent, viewController: ViewController) {
        self.viewController = viewController
        self.menuComponent = menuComponent
        self.headerComponent = headerComponent
        self.headerComponent.menuController = self
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
            case "Me":
                self.viewController.userManager.profileWindowComponent.render(parentView: parentView)
            default:
                print("Unexpected window name")
        }
    }
    
    func setKeyboardView() {
        self.headerComponent.view.removeFromSuperview()
        self.menuComponent.view.removeFromSuperview()
    }
    
    func unsetKeyboardView() {
        self.headerComponent.render(parentView: self.viewController.view)
        self.menuComponent.render(parentView: self.viewController.view)
    }
}


class MenuManager {
    var viewController: ViewController!
    var headerComponent: HeaderComponent!
    var menuComponent: MenuComponent!
    var menuController: MenuController!
    var userStateController: UserStateController!

    
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
        self.menuController = MenuController(
            menuComponent: self.menuComponent,
            headerComponent: self.headerComponent,
            viewController: self.viewController
        )
    }
    
    func render() {
        self.headerComponent.render(parentView: self.viewController.view)
        self.menuComponent.render(parentView: self.viewController.view)
    }
    
    func injectControllers(userStateController: UserStateController) {
        self.menuController.userStateController = userStateController
    }
}
