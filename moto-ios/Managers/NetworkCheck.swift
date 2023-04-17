//
//  NetworkCheck.swift
//  WhatBikesWin
//
//  Created by Caspar Wylie on 05/04/2023.
//

import Foundation
import Reachability
import UIKit

class BannerComponent {
    var view: UIView!
    var mainLabel: UILabel!
    
    func makeLabel() {
        self.mainLabel = Label().make(
            text: "Internet connection is required!", align: .center, size: 40, color: .black
        )
        self.mainLabel.frame = CGRect(
            x: 0, y: global_height / 3, width: global_width, height: 100
        )
    }
    
    func render (parentView: UIView) {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: global_width, height: global_height))
        self.view.backgroundColor = .white
        self.makeLabel()
        self.view.addSubview(self.mainLabel)
        parentView.addSubview(self.view)
    }
}

class NetworkCheckManager {
    var reachability: Reachability!
    var bannerComponent: BannerComponent!
    var parentView: UIView!
    
    init (mainView: UIView) {
        self.parentView = mainView
        self.makeComponents()
    }
    
    func makeComponents() {
        self.bannerComponent = BannerComponent()
    }
    
    func start() {
        self.reachability = try! Reachability()
        self.reachability.whenReachable = { reachability in
            self.bannerComponent.view?.removeFromSuperview()
        }
        self.reachability.whenUnreachable = { _ in
            self.bannerComponent.render(parentView: self.parentView)
        }
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    

}
