//
//  Utils.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import Foundation
import UIKit

func _get_center_x(width: Int) -> Int {
    return (global_width / 2) - (width / 2)
}

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
    label.textColor = .black
    return label
}


func _make_button (
    text: String
) -> UIButton {
    let button = UIButton()
    button.titleLabel?.font = UIFont(name: "ChakraPetch-Medium", size: 15)
    button.titleLabel?.textAlignment = .center
    button.setTitle(text, for: .normal)
    button.setTitleColor(.black, for: .normal)
    return button
}
