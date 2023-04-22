//
//  ViewController.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//

import UIKit
import SwiftUI
import Reachability


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
    var informerManager: InformerManager!
    var userManager: UserManager!
    var socialManager: SocialManager!
    var networkCheckManager: NetworkCheckManager!
    
    var racingApiClient: RacingApiClient!
    var userApiClient: UserApiClient!
    var socialApiClient: SocialApiClient!
    
    func sceneDelegate() -> SceneDelegate? {
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            return sd
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeApiClients()
        self.makeManagers()
        
        Task {
            await self.initialSetup()
        }
    }
    
    func makeApiClients() {
        self.racingApiClient = RacingApiClient(base_url: BASE_DOMAIN + "/api/racing")
        self.userApiClient = UserApiClient(base_url: BASE_DOMAIN + "/api/user")
        self.socialApiClient = SocialApiClient(base_url: BASE_DOMAIN + "/api/social")
    }
    
    func makeManagers() {
        self.informerManager = InformerManager(parentView: self.view)
        self.racingManager = RacingManager(apiClient: self.racingApiClient, parentView: self.view)
        self.menuManager = MenuManager(viewController: self)
        self.introductionManager = IntroductionManager(parentView: self.view)
        self.insightManager = InsightsManager(parentView: self.view, apiClient: self.racingApiClient)
        self.userManager = UserManager(apiClient: self.userApiClient, racingApiClient: self.racingApiClient, viewController: self)
        self.socialManager = SocialManager(apiClient: self.socialApiClient, parentView: self.view)
        self.networkCheckManager = NetworkCheckManager(mainView: self.view)
    }
    
    func injectDependencies() {
        self.racingManager.injectControllers(
            commentsController: self.socialManager.commentsController,
            informerController: self.informerManager.informerController
        )
        
        self.insightManager.injectControllers(
            raceController: self.racingManager.raceController
        )
        
        self.userManager.injectControllers(
            informerController: self.informerManager.informerController,
            myRecentRacesController: self.insightManager.myRecentRacesController,
            racerRecommendingController: self.racingManager.racerRecommendingController
        )
        
        self.socialManager.injectControllers(
            informerController: self.informerManager.informerController,
            userStateController: self.userManager.userStateController
        )
        
        self.menuManager.injectControllers(
            userStateController: self.userManager.userStateController
        )
    }
    
    func renderAll(isLoggedin: Bool) {
        self.informerManager.render()
        self.racingManager.render()
        self.userManager.render()
        self.menuManager.render()
        self.socialManager.render()
        
        self.networkCheckManager.start()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object:nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object:nil)
        
        await self.userManager.userStateController.setUser()
        self.injectDependencies()
        self.renderAll(isLoggedin: self.userManager.userStateController.isLoggedin())
        
    }
    
    @objc func keyboardWillShow() {
        self.menuManager.menuController.setKeyboardView()
        self.racingManager.raceController.setKeyboardView()
    }
    
    
    @objc func keyboardWillHide() {
        self.menuManager.menuController.unsetKeyboardView()
        self.racingManager.raceController.unsetKeyboardView()
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }


}

