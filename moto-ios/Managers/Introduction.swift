//
//  Introduction.swift
//  moto-ios
//
//  Created by Caspar Wylie on 21/03/2023.
//

import Foundation
import UIKit
import WebKit



class IntroductionWindowComponent: WindowComponent, WKUIDelegate {
    var webView: WKWebView!
    let contentRequestURL = URL(string: "\(BASE_DOMAIN)/intro.html")

    override init() {
        super.init()
        self.webView = WKWebView(
            frame: CGRect(
                x: 0,
                y: Self.headerOffset - Self.titleHeight,
                width: globalWidth,
                height: globalHeight - self.closeSize * 2
            ),
            configuration: WKWebViewConfiguration()
        )
        self.webView.uiDelegate = self
    }
    
    override func setWindowMeta() {
        self.title = ""
    }
    
    func renderWebView() {
        let request = URLRequest(url: self.contentRequestURL!)
        self.webView.load(request)
        self.view.addSubview(self.webView)
    }
    override func render(parentView: UIView) {
        super.render(parentView: parentView)
        self.renderWebView()
    }
}

class IntroductionManager {
    var parentView: UIView!
    var introductionWindowComponent: IntroductionWindowComponent!
    
    init (parentView: UIView) {
        self.parentView = parentView
        self.makeComponents()
    }
    
    func makeComponents() {
        self.introductionWindowComponent = IntroductionWindowComponent()
    }
    
    func render() {
        self.introductionWindowComponent.render(parentView: self.parentView)
    }
}
