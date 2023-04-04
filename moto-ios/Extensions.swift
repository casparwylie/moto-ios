//
//  Extensions.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import Foundation
import UIKit

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: 0, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }

    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width,y: 0, width:width, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }

    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:self.frame.size.height - width, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }

    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:0, width:width, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension UIButton {
    func addTouchDownEffect () {
        self.addTarget(self, action: #selector(self.shortChangeBackground), for: .touchDown)
    }
    @objc func shortChangeBackground(with color: UIColor) {
        UIView.animate(withDuration: 0.0) {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.5)
        }
        
        UIView.animate(withDuration: 0.1, delay: 0.3) {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
        }
    }
}
