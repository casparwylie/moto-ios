//
//  GeneralComponents.swift
//  moto-ios
//
//  Created by Caspar Wylie on 21/03/2023.
//

import Foundation
import UIKit



class WindowComponent: NSObject {
    var view: UIScrollView!
    var closeButton: UIButton!
    let closeSize = uiDef().HEADER_FONT_SIZE
    let titleWidth = global_width
    static let titleHeight = 100
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
        self.titleLabel = Label().make(
            text: self.title, align: .center, font: "Tourney", size: CGFloat(uiDef().HEADER_FONT_SIZE), color: self.titleColor
        )
        self.titleLabel.frame = CGRect(
            x: getCenterX(width: self.titleWidth),
            y: 5,
            width: self.titleWidth,
            height: Self.titleHeight
        )
    }
    
    func makeClose() {
        self.closeButton = Button().make(text: "✕", color: .white, size: self.closeSize)
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
        if let view = self.view {
            view.removeFromSuperview()
        }
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


class OptionListingComponent {

    var view: UIScrollView!
    var rows: [UIButton: () -> ()] = [:]
    let rowHeight = uiDef().ROW_HEIGHT
    let width = global_width / 3
    let maxHeight: CGFloat = 150
    
    var lastSelected: UIButton?
    var rowBorderColor: UIColor = .black
    let bottomBorderClip: CGFloat = 3
    

    func clear() {
        self.view.subviews.forEach {row in row.removeFromSuperview()}
        self.rows = [:]
        self.view.frame.size.height = 0
    }
    
    func addRow(text: String, callback: @escaping () -> ()) {
        let button = Button().make(text: text, color: .white)
        button.titleLabel!.lineBreakMode = .byTruncatingTail
        button.frame = CGRect(
            x: 0,
            y: 0,
            width: Int(self.view.frame.size.width),
            height: self.rowHeight
        )
        button.addBottomBorderWithColor(color: self.rowBorderColor, width: 1)
        
        button.addTarget(
            self, action: #selector(self.onRowSelect), for: .touchUpInside
        )
        self.rows[button] = callback
        
        let lastY = expandDown(views: Array(self.rows.keys), spacing: 2)
        self.view.frame.size.height = (
            (lastY > self.maxHeight) ? self.maxHeight : lastY
        ) - self.bottomBorderClip
        self.view.contentSize = (
            CGSize(width: CGFloat(self.width), height: lastY - self.bottomBorderClip)
        )
        self.view.addSubview(button)
    }
    
    
    @objc func onRowSelect(button: UIButton) {
        self.lastSelected = button
        self.rows[button]?()
    }
    
    func setFrame(frame: CGRect) {
        self.view.frame = frame
    }
    
    func render(parentView: UIView) {
        self.view = UIScrollView()
        self.view.layer.cornerRadius = uiDef().CORNER_RADIUS
        self.view.backgroundColor = _DARK_BLUE
        parentView.addSubview(self.view)
    }
}


class DropDownComponent {
    var view: UIView!
    var listingComponent: OptionListingComponent!
    var toggleButton: UIButton!
    var height = CGFloat(uiDef().ROW_HEIGHT)
        
    init() {
        self.listingComponent = OptionListingComponent()
    }
    
    func addRow(text: String, callback: @escaping () -> ()) {
        self.listingComponent.addRow(text: text) {
            self.close()
            self.setTitle(title: text)
            callback()
        }
        self.view.frame.size.height = self.listingComponent.view.frame.size.height + self.height
    }
    
    func getLastSelectedText() -> String {
        return self.listingComponent.lastSelected?.titleLabel?.text ?? ""
    }
    
    func close () {
        hide(view: self.listingComponent.view)
    }
    
    func setTitle(title: String) {
        self.toggleButton.setTitle("\(title)˅", for: .normal)
    }

    func makeToggleButton() {
        self.toggleButton = Button().make(text: "", background: .black, color: .white)
        self.toggleButton.addTarget(self, action: #selector(self.onTogglePress), for: .touchDown)
    }
    
    @objc func onTogglePress () {
        self.listingComponent.view.isHidden = !self.listingComponent.view.isHidden
    }
    
    func setFrame(frame: CGRect) {
        self.view.frame = frame
        self.listingComponent.setFrame(frame: CGRect(x: 0, y: self.height, width: frame.width, height: 0))
        self.toggleButton.frame = CGRect(x: 0, y: 0, width: frame.width, height: self.height)
    }
    
    func render(parentView: UIView) {
        self.view = UIView()
        self.makeToggleButton()
        self.view.addSubview(self.toggleButton)
        self.listingComponent.render(parentView: self.view)
        self.listingComponent.clear()
        self.close()
        parentView.addSubview(self.view)
    }
}
