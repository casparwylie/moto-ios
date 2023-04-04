//
//  ViewController.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import UIKit
import SwiftUI


var global_width = Int(UIScreen.main.bounds.size.width)
var global_height = Int(UIScreen.main.bounds.size.height)

let BASE_DOMAIN = "https://whatbikeswin.com"


func switchRenderOrientation() {
    if (global_width < global_height) {
        let fwidth = global_width
        global_width = global_height
        global_height = fwidth
    }
}


class ViewController: UIViewController {
    
    var racingManager: RacingManager!
    var menuManager: MenuManager!
    var introductionManager: IntroductionManager!
    var insightManager: InsightsManager!
    var informManager: InformerManager!
    var userManager: UserManager!
    var socialManager: SocialManager!
    
    let racingApiClient = RacingApiClient(base_url: BASE_DOMAIN + "/api/racing")
    let userApiClient = UserApiClient(base_url: BASE_DOMAIN + "/api/user")
    let socialApiClient = SocialApiClient(base_url: BASE_DOMAIN + "/api/social")
    
    func sceneDelegate() -> SceneDelegate? {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            return sd
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

            self.informManager = InformerManager(parentView: self.view)
        
            self.userManager = UserManager(
                apiClient: self.userApiClient, informer: informManager, viewController: self
            )
        
            self.socialManager = SocialManager(
                informer: self.informManager,
                userStateController: self.userManager.userStateController,
                apiClient: self.socialApiClient,
                parentView: self.view
            )
        
            self.racingManager = RacingManager(
                apiClient: self.racingApiClient,
                informer: informManager,
                socialManager: socialManager,
                parentView: self.view
            )
 
        
            self.menuManager = MenuManager(viewController: self)
        
            self.introductionManager = IntroductionManager(parentView: self.view)
        
            self.insightManager = InsightsManager(
                parentView: self.view,
                apiClient: racingApiClient,
                raceController: racingManager.raceController
            )
        
        Task {
            await self.initialSetup()
            self.renderAll(isLoggedin: self.userManager.userStateController.isLoggedin())
        }
    }
    
    func renderAll(isLoggedin: Bool) {
        self.informManager.render()
        self.racingManager.render()
        self.userManager.render()
        self.menuManager.render(isLoggedin: isLoggedin)
        self.socialManager.render()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    @MainActor @objc func appDidBecomeActive() {
        if let url = self.sceneDelegate()?.shareUrl {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let raceId = (components?.queryItems?.first(where: { $0.name == "shareRaceId" })?.value)
            Task {
                if let race = await self.racingManager.apiClient.getRace(raceId: raceId) {
                    self.racingManager.raceController.setRacersFromRace(race: race)
                    self.racingManager.raceController.startRace()
                }
            }
        }
    }
    
    func initialSetup() async {
        // Ensure landscape orientation
        switchRenderOrientation()
        
        // Events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // Set basic UI
        self.view.backgroundColor = .white
        
        // Setup Keyboard dismissing
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        await self.userManager.userStateController.setUser()
        
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }


}

