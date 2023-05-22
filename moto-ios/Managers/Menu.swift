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
    static let y = 30
    let headerLabelSize = uiDef().HEADER_FONT_SIZE
    let creditLabelSize = uiDef().ROW_HEIGHT
    static let height = uiDef().HEADER_FONT_SIZE + uiDef().FONT_SIZE
    var headerLabel: UILabel!
    var creditLabel: UILabel!
    
    var menuController: MenuController?

    func makeHeaderLabel() {
        self.headerLabel = Label().make(
            text: "What Bikes Win?", font: "Faster One", size: CGFloat(self.headerLabelSize)
        )
        self.headerLabel.frame = CGRect(x: 0, y: 0, width: globalWidth, height: self.headerLabelSize)
    }
    
    func makeHeaderCreditLabel() {
        var text = "Enter the make and models of the motorcycles you want to race..."
        if let username = self.menuController?.userStateController?.currentUser?.username {
            text = "Welcome, \(username)"
        }
        self.creditLabel = Label().make(text: text, font: "Tourney", size: CGFloat(uiDef().FONT_SIZE), color: _LIGHT_GREY)
        self.creditLabel.frame = CGRect(
            x: 0, y: Int(self.headerLabel.frame.height + 5), width: globalWidth, height: self.creditLabelSize
        )
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: getCenterX(width: globalWidth),
                y: Self.y,
                width: globalWidth,
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
        self.button.frame.origin.x = 40
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
    var menuOption: UIImageView!
    var closeOption: Button!
    
    static let height = uiDef().ROW_HEIGHT
    var menuItems: [MenuItemComponent] = []
    let spacing = 10
    let menuWidth = 170
    let menuOptionSize = 30
    let closeSize = 20
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
    
    func renderCloseOption() {
        self.closeOption = Button().make(text: "✕", size: 20)
        self.closeOption.frame = CGRect(
            x: self.menuWidth - self.closeSize - 5, y: 10, width: self.closeSize, height: self.closeSize
        )
        self.closeOption.addTarget(self, action: #selector(self.onMenuClosePress), for: .touchDown)
        self.view.addSubview(self.closeOption)
    }
    
    func renderMenuOption(parentView: UIView) {
        self.menuOption = UIImageView()
        self.menuOption.image = UIImage(named: "images/menu_icon")
        self.menuOption.frame = CGRect(x: 20, y: 30, width: self.menuOptionSize, height: self.menuOptionSize)
        self.menuOption.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onMenuOptionPress))
        self.menuOption.addGestureRecognizer(tap)
        parentView.addSubview(self.menuOption)
    }
    
    @objc func onMenuOptionPress() {
        self.showMenu()
    }
    
    @objc func onMenuClosePress() {
        self.hideMenu()
    }
    
    func showMenu() {
        show(view: self.view)
    }
    
    func hideMenu() {
        hide(view: self.view)
    }

    func render(parentView: UIView) {
        self.view = UIView()
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowColor = UIColor.gray.cgColor
        self.view.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.view.backgroundColor = _YELLOW
        self.view.frame = CGRect(
            x: 0,
            y: 0,
            width: self.menuWidth,
            height: globalHeight
        )
        hide(view: self.view)
        
        let isLoggedin = (self.menuController?.userStateController?.isLoggedin())!
        self.setMenuItems(isLoggedin: isLoggedin)
        self.menuItems.forEach { item in item.render(parentView: self.view) }
        _ = expandDown(views: self.menuItems.map {$0.button}, startY: 30, spacing: 15)

        self.renderCloseOption()
        self.renderMenuOption(parentView: parentView)
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
        hide(view: self.headerComponent.view)
    }
    
    func unsetKeyboardView() {
        show(view: self.headerComponent.view)
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
