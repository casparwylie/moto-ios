//
//  User.swift
//  moto-ios
//
//  Created by Caspar Wylie on 30/03/2023.
//

import Foundation
import UIKit


class SignUpWindowComponent: WindowComponent {

    var usernameIn: UITextField!
    var emailIn: UITextField!
    var passwordIn: UITextField!
    var vpasswordIn: UITextField!
    var submitButton: UIButton!
    
    let inputWidth = Int(Double(global_width) * 0.7)
    
    var signUpController: SignUpController?

    override func setWindowMeta() {
        self.title = "Sign Up"
    }
    
    func reset() {
        self.usernameIn.text = ""
        self.emailIn.text = ""
        self.passwordIn.text = ""
        self.vpasswordIn.text = ""
    }
    
    func makeInputs() {
        let inputFrame = CGRect(
            x: _get_center_x(width: self.inputWidth), y: 0, width: self.inputWidth, height: 30
        )
        
        self.usernameIn = _make_text_input(text: "Username...")
        self.usernameIn.frame = inputFrame
        
        self.emailIn = _make_text_input(text: "Email...")
        self.emailIn.frame = inputFrame
        
        self.passwordIn = _make_text_input(text: "Password...")
        self.passwordIn.frame = inputFrame
        self.passwordIn.isSecureTextEntry = true
        
        self.vpasswordIn = _make_text_input(text: "Verify Password...")
        self.vpasswordIn.frame = inputFrame
        self.vpasswordIn.isSecureTextEntry = true
        
        self.submitButton = _make_button(text: "Sign Up", background: .black, color: .white)
        self.submitButton.frame = CGRect(
            x: _get_center_x(width: self.inputWidth), y: 0, width: self.inputWidth / 3, height: 30
        )
        self.submitButton.addTarget(self, action: #selector(self.onSubmitPress), for: .touchDown)
        
        _ = _expand_as_list(
            views: [self.usernameIn, self.emailIn, self.passwordIn, self.vpasswordIn, self.submitButton],
            startY: CGFloat(self.titleHeight)
        )
    }
    
    @MainActor @objc func onSubmitPress() {
        self.signUpController?.signUpUser(
            username: self.usernameIn.text!,
            email: self.emailIn.text!,
            password: self.passwordIn.text!,
            vpassword: self.vpasswordIn.text!
        )
    }
    
    func render(parentView: UIView) {
        super.render()
        self.makeInputs()
        self.view.addSubview(self.usernameIn)
        self.view.addSubview(self.emailIn)
        self.view.addSubview(self.passwordIn)
        self.view.addSubview(self.vpasswordIn)
        self.view.addSubview(self.submitButton)
        parentView.addSubview(self.view)
    }
}

class LoginWindowComponent: WindowComponent {
    
    var usernameIn: UITextField!
    var passwordIn: UITextField!
    var submitButton: UIButton!
    
    let inputWidth = Int(Double(global_width) * 0.6)
    
    var loginController: LoginController?
    
    override func setWindowMeta() {
        self.title = "Login"
    }
    
    func reset() {
        self.usernameIn.text = ""
        self.passwordIn.text = ""
    }
    
    func makeInputs() {
        let inputFrame = CGRect(
            x: _get_center_x(width: self.inputWidth), y: 0, width: self.inputWidth, height: 30
        )
        
        self.usernameIn = _make_text_input(text: "Username...")
        self.usernameIn.frame = inputFrame

        self.passwordIn = _make_text_input(text: "Password...")
        self.passwordIn.frame = inputFrame
        self.passwordIn.isSecureTextEntry = true

        self.submitButton = _make_button(text: "Login", background: .black, color: .white)
        self.submitButton.frame = CGRect(
            x: _get_center_x(width: self.inputWidth), y: 0, width: self.inputWidth / 3, height: 30
        )
        self.submitButton.addTarget(self, action: #selector(self.onSubmitPress), for: .touchDown)
        
        _ = _expand_as_list(
            views: [self.usernameIn, self.passwordIn, self.submitButton],
            startY: CGFloat(self.titleHeight)
        )
    }
    
    @MainActor @objc func onSubmitPress() {
        self.loginController?.loginUser(
            username: self.usernameIn.text!,
            password: self.passwordIn.text!
        )
    }
    
    func render(parentView: UIView) {
        super.render()
        self.makeInputs()
        self.view.addSubview(self.usernameIn)
        self.view.addSubview(self.passwordIn)
        self.view.addSubview(self.submitButton)
        parentView.addSubview(self.view)
    }
    
}


class SignUpController {
    var apiClient: UserApiClient!
    var signUpWindowComponent: SignUpWindowComponent!
    var informer: InformerManager!
    
    init (signUpWindowComponent: SignUpWindowComponent, informer: InformerManager, apiClient: UserApiClient) {
        self.apiClient = apiClient
        self.signUpWindowComponent = signUpWindowComponent
        self.informer = informer
        self.signUpWindowComponent.signUpController = self
    }
    
    @MainActor func signUpUser(username: String, email: String, password: String, vpassword: String) {
        if (
            username.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || email.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || password.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || vpassword.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
        ) {
            self.informer.inform(message: "All fields are required.", mood: "bad")
            return
        }
        if (password != vpassword) {
            self.informer.inform(message: "Passwords do not match.", mood: "bad")
            return
        }

        Task {
            if let response = await self.apiClient.signupUser(username: username, email: email, password: password) {
                if response.errors.count > 0 {
                    self.informer.inform(message: response.errors[0], mood: "bad")
                } else {
                    self.finishSuccessfulSignUp()
                }
            }
        }
    }
    
    func finishSuccessfulSignUp() {
        self.informer.inform(message: "Successfully signed up!")
        self.signUpWindowComponent.reset()
        self.signUpWindowComponent.view.removeFromSuperview()
    }
}


class LoginController {
    var apiClient: UserApiClient!
    var loginWindowComponent: LoginWindowComponent!
    var informer: InformerManager!
    var userStateController: UserStateController!
    
    init (
        loginWindowComponent: LoginWindowComponent,
        informer: InformerManager,
        apiClient: UserApiClient,
        userStateController: UserStateController
    ) {
        self.apiClient = apiClient
        self.loginWindowComponent = loginWindowComponent
        self.informer = informer
        self.userStateController = userStateController
        self.loginWindowComponent.loginController = self
    }
    
    @MainActor func loginUser(username: String, password: String) {
        if (
            username.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || password.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
        ) {
            self.informer.inform(message: "All fields are required.", mood: "bad")
            return
        }
        Task {
            if let response = await self.apiClient.loginUser(username: username, password: password) {
                if response.success {
                    self.finishSuccessfulLogin()
                } else {
                    self.informer.inform(message: "Incorrect username or password.", mood: "bad")
                }
            }
        }
    }
    
    @MainActor func finishSuccessfulLogin() {
        self.loginWindowComponent.reset()
        self.loginWindowComponent.view.removeFromSuperview()
        Task {
            await self.userStateController.setUser()
            self.userStateController.viewController.renderAll(
                isLoggedin: self.userStateController.isLoggedin()
            )
            self.informer.inform(message: "Successfully logged in!")
        }
    }
}


class UserStateController {
    var apiClient: UserApiClient!
    var viewController: ViewController!
    var informer: InformerManager!

    var currentUser: UserResponseModel?
    
    init (apiClient: UserApiClient,  informer: InformerManager, viewController: ViewController) {
        self.apiClient = apiClient
        self.viewController = viewController
        self.informer = informer
    }
    
    func isLoggedin() -> Bool {
        return self.currentUser != nil
    }
    
    func setUser() async {
        self.currentUser = await self.apiClient.getUser()
    }
    
    @MainActor func logoutUser() {
        Task {
            _ = await self.apiClient.logoutUser()
            await self.setUser()
            self.viewController.renderAll(isLoggedin: self.isLoggedin())
            self.informer.inform(message: "Successfully logged out!")
        }
    }
}

class UserManager {
    var apiClient: UserApiClient!
    var parentView: UIView!
    var informer: InformerManager!
    var viewController: ViewController!
    
    var signUpWindowComponent: SignUpWindowComponent!
    var loginWindowComponent: LoginWindowComponent!
    
    var signUpController: SignUpController!
    var loginController: LoginController!
    var userStateController: UserStateController!
    

    
    init(apiClient: UserApiClient, informer: InformerManager, viewController: ViewController) {
        self.apiClient = apiClient
        self.informer = informer
        self.parentView = viewController.view
        self.viewController = viewController
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents() {
        self.signUpWindowComponent = SignUpWindowComponent()
        self.loginWindowComponent = LoginWindowComponent()
    }
    
    func makeControllers() {
        self.userStateController = UserStateController(
            apiClient: self.apiClient,
            informer: self.informer,
            viewController: self.viewController
        )
        self.signUpController = SignUpController(
            signUpWindowComponent: self.signUpWindowComponent,
            informer: self.informer,
            apiClient: self.apiClient
        )
        self.loginController = LoginController(
            loginWindowComponent: self.loginWindowComponent,
            informer: self.informer,
            apiClient: self.apiClient,
            userStateController: self.userStateController
        )

    }

    
    func render() {
        
    }
}
