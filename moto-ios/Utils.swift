//
//  Utils.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import Foundation
import UIKit


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
    color: UIColor = .black
) -> UIButton {
    let button = UIButton()
    button.titleLabel?.font = UIFont(name: "ChakraPetch-Medium", size: 15)
    button.titleLabel?.textAlignment = .center
    button.setTitle(text, for: .normal)
    button.setTitleColor(color, for: .normal)
    button.backgroundColor = background
    button.layer.cornerRadius = 5
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

