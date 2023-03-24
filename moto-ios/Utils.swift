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


class TextField: UITextField {

    let padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var group = 0

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}


func _get_center_x(width: Int) -> Int {
    return (global_width / 2) - (width / 2)
}


func _get_center_y(height: Int) -> Int {
    return (global_height / 2) - (height / 2)
}


func _make_text (
    text: String,
    align: NSTextAlignment = .center,
    font: String = "ChakraPetch-Medium",
    size: CGFloat = 15,
    color: UIColor = .black
) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    label.textAlignment = align
    label.font = UIFont(name: font, size: size)
    label.text = text
    label.textColor = color
    return label
}


func _make_button (
    text: String,
    background: UIColor? = nil,
    color: UIColor = .black,
    size: Int = 15
) -> UIButton {
    let button = UIButton()
    button.titleLabel?.font = UIFont(name: "ChakraPetch-Medium", size: CGFloat(size))
    button.titleLabel?.textAlignment = .center
    button.setTitle(text, for: .normal)
    button.setTitleColor(color, for: .normal)
    button.backgroundColor = background
    button.layer.cornerRadius = 5
    button.titleLabel?.lineBreakMode = .byWordWrapping
    return button
}

func _make_text_input(text: String) -> TextField {
    let textField = TextField()
    textField.attributedPlaceholder = NSAttributedString(
        string: text,
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
    )
    textField.backgroundColor = .black
    textField.textColor = .white
    textField.layer.cornerRadius = 5
    textField.font =  UIFont(name: "ChakraPetch-Medium", size: 15)
    return textField
}


func _hide(view: UIView) {
    view.isHidden = true
}


func _show(view: UIView) {
    view.isHidden = false
}


func _expand_as_list(views: [UIView], startY: CGFloat = 0, spacing: CGFloat = 5) -> CGFloat {
    var lastHeight: CGFloat = 0
    var lastY: CGFloat = startY
    for view in views {
        view.frame.origin.y = lastY
        lastHeight = view.frame.size.height
        lastY += (lastHeight + spacing)
    }
    return lastY
}

func _expand_across(views: [UIView], startX: CGFloat = 0, spacing: CGFloat = 5) -> CGFloat {
    var lastWidth: CGFloat = 0
    var lastX: CGFloat = startX
    for view in views {
        view.frame.origin.x = lastX
        lastWidth = view.frame.size.width
        lastX += (lastWidth + spacing)
    }
    return lastX
}

