//
//  Utils.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import Foundation
import UIKit


let _DARK_BLUE = UIColor(red: 0.00, green: 0.18, blue: 0.35, alpha: 1.00)
let _GREEN = UIColor(red: 0.22, green: 0.68, blue: 0.53, alpha: 1.00)
let _YELLOW = UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.00)
let _RED = UIColor(red: 1.00, green: 0.30, blue: 0.30, alpha: 1.00)
let _BLUE = UIColor(red: 0.20, green: 0.60, blue: 1.00, alpha: 1.00)
let _DARK_TBLUE = UIColor(red: 0.00, green: 0.49, blue: 0.49, alpha: 1.00)
let _DARK2_TBLUE = UIColor(red: 0.00, green: 0.33, blue: 0.33, alpha: 1.00)
let _LIGHT_GREY = UIColor(red: 0.72, green: 0.72, blue: 0.72, alpha: 1.00)


class UIDefaults {
    var ROW_HEIGHT: Int { return 30 }
    var FONT_SIZE:  Int { return 15 }
    var HEADER_FONT_SIZE: Int { return 25 }
    var CORNER_RADIUS: CGFloat { return 5 }
    var MAX_RACERS_PER_RACE: Int { return 6 }
    var HEADER_IMAGE_SIZE: Int { return 130 }
}

class iPadUIDefaults: UIDefaults {
    override var ROW_HEIGHT: Int { return 50 }
    override var FONT_SIZE:  Int { return 25 }
    override var HEADER_FONT_SIZE: Int { return 35 }
    override var MAX_RACERS_PER_RACE: Int { return 8 }
    override var HEADER_IMAGE_SIZE: Int { return 200 }
}

func uiDef() -> UIDefaults {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return iPadUIDefaults()
    }
    return UIDefaults()
}


func getCenterX(width: Int) -> Int {
    return (global_width / 2) - (width / 2)
}


func getCenterY(height: Int) -> Int {
    return (global_height / 2) - (height / 2)
}


class Label: UILabel {
    func make (
        text: String,
        align: NSTextAlignment = .center,
        font: String = "ChakraPetch-Medium",
        size: CGFloat = CGFloat(uiDef().FONT_SIZE),
        color: UIColor = .black
    ) -> Label {
        self.textAlignment = align
        self.font = UIFont(name: font, size: size)
        self.text = text
        self.textColor = color
        return self
    }
}


class Button: UIButton {
    func make(
        text: String,
        background: UIColor? = nil,
        color: UIColor = .black,
        size: Int = uiDef().FONT_SIZE
    ) -> Button {
        self.addTouchDownEffect()
        self.titleLabel?.font = UIFont(name: "ChakraPetch-Medium", size: CGFloat(size))
        self.titleLabel?.textAlignment = .center
        self.setTitle(text, for: .normal)
        self.setTitleColor(color, for: .normal)
        self.backgroundColor = background
        self.layer.cornerRadius = uiDef().CORNER_RADIUS
        self.titleLabel?.lineBreakMode = .byWordWrapping
        return self
    }
}

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func make(text: String) -> TextField {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        self.autocapitalizationType = .none
        self.backgroundColor = .black
        self.textColor = .white
        self.layer.cornerRadius = uiDef().CORNER_RADIUS
        self.font =  UIFont(name: "ChakraPetch-Medium", size: CGFloat(uiDef().FONT_SIZE))
        return self
    }
}

class TextBox: UITextView {
    func make() -> TextBox {
        self.isEditable = true
        self.isUserInteractionEnabled = true
        self.isScrollEnabled = true
        self.backgroundColor = .black
        self.textColor = .white
        self.font =  UIFont(name: "ChakraPetch-Medium", size: CGFloat(uiDef().FONT_SIZE))
        self.layer.cornerRadius = uiDef().CORNER_RADIUS
        return self
    }
}


func hide(view: UIView) {
    view.isHidden = true
}


func show(view: UIView) {
    view.isHidden = false
}


func expandDown(views: [UIView], startY: CGFloat = 0, spacing: CGFloat = 5) -> CGFloat {
    var lastHeight: CGFloat = 0
    var lastY: CGFloat = startY
    for view in views {
        view.frame.origin.y = lastY
        lastHeight = view.frame.size.height
        lastY += (lastHeight + spacing)
    }
    return lastY
}

func expandAcross(views: [UIView], startX: CGFloat = 0, spacing: CGFloat = 5) -> CGFloat {
    var lastWidth: CGFloat = 0
    var lastX: CGFloat = startX
    for view in views {
        view.frame.origin.x = lastX
        lastWidth = view.frame.size.width
        lastX += (lastWidth + spacing)
    }
    return lastX
}

