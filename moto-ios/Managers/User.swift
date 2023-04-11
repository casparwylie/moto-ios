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
    
    override func render(parentView: UIView) {
        self.makeInputs()
        self.view.addSubview(self.usernameIn)
        self.view.addSubview(self.emailIn)
        self.view.addSubview(self.passwordIn)
        self.view.addSubview(self.vpasswordIn)
        self.view.addSubview(self.submitButton)
        super.render(parentView: parentView)
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
    
    override func render(parentView: UIView) {
        self.makeInputs()
        super.render(parentView: parentView)
        self.view.addSubview(self.usernameIn)
        self.view.addSubview(self.passwordIn)
        self.view.addSubview(self.submitButton)
    }
    
}


class SignUpController {
    var apiClient: UserApiClient!
    var signUpWindowComponent: SignUpWindowComponent!
    var informerController: InformerController?
    
    init (signUpWindowComponent: SignUpWindowComponent, apiClient: UserApiClient) {
        self.apiClient = apiClient
        self.signUpWindowComponent = signUpWindowComponent
        self.signUpWindowComponent.signUpController = self
    }
    
    @MainActor func signUpUser(username: String, email: String, password: String, vpassword: String) {
        if (
            username.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || email.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || password.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || vpassword.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
        ) {
            self.informerController?.inform(message: "All fields are required.", mood: "bad")
            return
        }
        if (password != vpassword) {
            self.informerController?.inform(message: "Passwords do not match.", mood: "bad")
            return
        }

        Task {
            if let response = await self.apiClient.signupUser(username: username, email: email, password: password) {
                if response.errors.count > 0 {
                    self.informerController?.inform(message: response.errors[0], mood: "bad")
                } else {
                    self.finishSuccessfulSignUp()
                }
            }
        }
    }
    
    func finishSuccessfulSignUp() {
        self.informerController?.inform(message: "Successfully signed up!")
        self.signUpWindowComponent.reset()
        self.signUpWindowComponent.view.removeFromSuperview()
    }
}


class LoginController {
    var apiClient: UserApiClient!
    var loginWindowComponent: LoginWindowComponent!
    var informerController: InformerController?
    var userStateController: UserStateController!
    
    init (
        loginWindowComponent: LoginWindowComponent,
        apiClient: UserApiClient
    ) {
        self.apiClient = apiClient
        self.loginWindowComponent = loginWindowComponent
        self.loginWindowComponent.loginController = self
    }
    
    @MainActor func loginUser(username: String, password: String) {
        if (
            username.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            || password.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
        ) {
            self.informerController?.inform(message: "All fields are required.", mood: "bad")
            return
        }
        Task {
            if let response = await self.apiClient.loginUser(username: username, password: password) {
                if response.success {
                    self.finishSuccessfulLogin()
                } else {
                    self.informerController?.inform(message: "Incorrect username or password.", mood: "bad")
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
            self.informerController?.inform(message: "Successfully logged in!")
        }
    }
}


class UserStateController {
    var apiClient: UserApiClient!
    var viewController: ViewController!
    var informerController: InformerController?

    var currentUser: UserResponseModel?
    
    init (apiClient: UserApiClient, viewController: ViewController) {
        self.apiClient = apiClient
        self.viewController = viewController
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
            self.informerController?.inform(message: "Successfully logged out!")
        }
    }
}



class ProfileTabButtonComponent {
    var button: UIButton!
    var name: String!
    var targetWindow: WindowComponent!
    
    var meController: MeController?
    
    init(name: String, targetWindow: WindowComponent?) {
        self.name = name
        self.targetWindow = targetWindow
    }
    
    func makeTabButton() {
        self.button = _make_button(text: self.name, background: .black, color: .white, size: 20)
        self.button.frame = CGRect(x: 0, y: 0, width: global_width / 5, height: 60)
        self.button.addTarget(self, action: #selector(self.openWindow), for: .touchDown)
    }
    
    @objc func openWindow() {
        self.targetWindow.render(parentView: self.meController!.parentView)
    }
  
    
    func render(parentView: UIView) {
        self.makeTabButton()
        parentView.addSubview(self.button)
    }
}


class MyGarageWindowComponent: WindowComponent {
    var meController: MeController?
    
    override func setWindowMeta() {
        self.title = "Me > My Garage"
    }
}


class ChangePasswordWindowComponent: WindowComponent {
    var meController: MeController?
    
    var passwordInputsView: UIView!
    
    var oldPasswordIn: UITextField!
    var newPasswordIn: UITextField!
    var vPasswordIn: UITextField!
    var submitButton: UIButton!
    
    var inputWidth = Int(Double(global_width) * 0.7)

    
    override func setWindowMeta() {
        self.title = "Me > Change Password"
    }
    
    func makePasswordInputs() {
        let inputFrame = CGRect(
            x: _get_center_x(width: self.inputWidth), y: 0, width: self.inputWidth, height: 30
        )
        self.oldPasswordIn = _make_text_input(text: "Current Password...")
        self.oldPasswordIn.frame = inputFrame
        self.oldPasswordIn.isSecureTextEntry = true
        
        self.newPasswordIn = _make_text_input(text: "New Password...")
        self.newPasswordIn.frame = inputFrame
        self.newPasswordIn.isSecureTextEntry = true
        
        self.vPasswordIn = _make_text_input(text: "Verify Password...")
        self.vPasswordIn.frame = inputFrame
        self.vPasswordIn.isSecureTextEntry = true
        
        self.submitButton = _make_button(text: "Change", background: .black, color: .white)
        self.submitButton.frame = inputFrame
        self.submitButton.frame.size.width = CGFloat(self.inputWidth / 3)
        self.submitButton.addTarget(self, action: #selector(self.onSubmitPress), for: .touchDown)
        
        _ = _expand_as_list(
            views: [self.oldPasswordIn, self.newPasswordIn, self.vPasswordIn, self.submitButton],
            startY: CGFloat(self.titleHeight)
        )
    }
    
    @MainActor @objc func onSubmitPress() {
        self.meController?.changePassword(
            oldPassword: self.oldPasswordIn.text!,
            newPassword: self.newPasswordIn.text!,
            vPassword: self.vPasswordIn.text!
        )
    }
    
    override func render(parentView: UIView) {
        super.render(parentView: parentView)
        self.makePasswordInputs()
        self.view.addSubview(self.oldPasswordIn)
        self.view.addSubview(self.newPasswordIn)
        self.view.addSubview(self.vPasswordIn)
        self.view.addSubview(self.submitButton)

    }

}


class EditProfileWindowComponent: WindowComponent {
    var meController: MeController?
    
    override func setWindowMeta() {
        self.title = "Me > Edit Profile"
    }

}


class ProfileWindowComponent: WindowComponent {
    
    var meController: MeController?
    
    var tabButtonComponents: [ProfileTabButtonComponent] = []
    
    var tabButtonView: UIView!
    var userInfoLabel: UILabel!
    
    let userInfoHeight = 50
    var tabButtonsHeight = 50
    
    override func setWindowMeta() {
        self.title = "Me > My Profile"
    }
    
    func setTabButtons () {
        self.tabButtonComponents = [
            ProfileTabButtonComponent(
                name: "View My Garage",
                targetWindow: self.meController?.myGarageWindowComponent
            ),
            ProfileTabButtonComponent(
                name: "View My Recent Races",
                targetWindow: self.meController?.myRecentRacesController?.windowComponent
            ),
            ProfileTabButtonComponent(
                name: "Change Password",
                targetWindow: self.meController?.changePasswordWindowComponent
            ),
            ProfileTabButtonComponent(
                name: "Edit Profile",
                targetWindow: self.meController?.editProfileWindowComponent
            )
        ]
    }
    
    func makeUserInfo() {
        let email = (self.meController?.userStateController?.currentUser?.email)!
        let username = (self.meController?.userStateController?.currentUser?.username)!
        let infoText = "Email: \(email) \n Username: \(username)"
        self.userInfoLabel = _make_text(text: infoText, align: .center)
        self.userInfoLabel.numberOfLines = 0
        self.userInfoLabel.lineBreakMode = .byWordWrapping
        self.userInfoLabel.frame = CGRect(
            x: _get_center_x(width: global_width),
            y: self.titleHeight,
            width: global_width,
            height: self.userInfoHeight
        )
    }
    
    func makeTabButtons() {
        self.tabButtonView = UIView(
            frame: CGRect(
                x: 0,
                y: self.titleHeight + self.userInfoHeight + 20,
                width: 0,
                height: self.tabButtonsHeight
            )
        )
        for tabButtonComponent in self.tabButtonComponents {
            tabButtonComponent.render(parentView: self.tabButtonView)
            self.tabButtonView.addSubview(tabButtonComponent.button)
            tabButtonComponent.meController = self.meController
        }
        let lastX = _expand_across(views: self.tabButtonComponents.map{ $0.button })
        self.tabButtonView.frame.size.width = lastX
        self.tabButtonView.frame.origin.x = CGFloat(_get_center_x(width: Int(lastX)))
    }

    override func render(parentView: UIView) {
        self.setTabButtons()
        self.makeTabButtons()
        self.meController?.setUser()
        self.makeUserInfo()
        super.render(parentView: parentView)
        self.view.addSubview(self.self.userInfoLabel)
        self.view.addSubview(self.tabButtonView)
    }

}

class MeController {
    var profileWindowComponent: ProfileWindowComponent!
    var myGarageWindowComponent: MyGarageWindowComponent!
    var editProfileWindowComponent: EditProfileWindowComponent!
    var changePasswordWindowComponent: ChangePasswordWindowComponent!

   
    
    var informerController: InformerController?
    var apiClient: UserApiClient!
    var userStateController: UserStateController?
    var myRecentRacesController: InsightController?
    var parentView: UIView!

    
    init(
        profileWindowComponent: ProfileWindowComponent,
        myGarageWindowComponent: MyGarageWindowComponent,
        editProfileWindowComponent: EditProfileWindowComponent,
        changePasswordWindowComponent: ChangePasswordWindowComponent,
        parentView: UIView,
        apiClient: UserApiClient
    ) {
        self.profileWindowComponent = profileWindowComponent
        self.myGarageWindowComponent = myGarageWindowComponent
        self.editProfileWindowComponent = editProfileWindowComponent
        self.changePasswordWindowComponent = changePasswordWindowComponent
        
        self.parentView = parentView
        self.apiClient = apiClient
        
        self.profileWindowComponent.meController = self
        self.myGarageWindowComponent.meController = self
        self.changePasswordWindowComponent.meController = self

    }
    
    func setUser() {
        if let userId = self.userStateController?.currentUser?.user_id {
            self.myRecentRacesController?.apiFlags = ["user_id": String(userId)]
        }
    }
    
    @MainActor func changePassword(oldPassword: String, newPassword: String, vPassword: String) {
        if (oldPassword.count > 0 && newPassword.count > 0 && vPassword.count > 0) {
            if (newPassword == vPassword) {
                Task {
                    if let response = await self.apiClient.changePassword(
                        oldPassword: oldPassword,
                        newPassword: newPassword
                    ) {
                        if response.errors.count > 0 {
                            self.informerController?.inform(message: response.errors[0], mood: "bad")
                        } else {
                            self.informerController?.inform(message: "Successfully changed!")
                            self.changePasswordWindowComponent.view.removeFromSuperview()
                        }
                    }
                }
            } else {
                self.informerController?.inform(message: "Passwords do not match.", mood: "bad")
            }
        }
    }
}


class UserManager {
    var apiClient: UserApiClient!
    var parentView: UIView!
    var informerController: InformerController?
    var myRecentRacesController: InsightController!
    var viewController: ViewController!
    
    var signUpWindowComponent: SignUpWindowComponent!
    var loginWindowComponent: LoginWindowComponent!
    var profileWindowComponent: ProfileWindowComponent!
    var myRecentRacesWindowComponent: MyRecentRacesWindowComponent!
    var myGarageWindowComponent: MyGarageWindowComponent!
    var changePasswordWindowComponent: ChangePasswordWindowComponent!
    var editProfileWindowComponent: EditProfileWindowComponent!
    
    var signUpController: SignUpController!
    var loginController: LoginController!
    var userStateController: UserStateController!
    var meController: MeController!
    
    
    init(
        apiClient: UserApiClient,
        viewController: ViewController
    ) {
        self.apiClient = apiClient
        self.parentView = viewController.view
        self.viewController = viewController
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents() {
        self.signUpWindowComponent = SignUpWindowComponent()
        self.loginWindowComponent = LoginWindowComponent()
        self.profileWindowComponent = ProfileWindowComponent()
        self.myGarageWindowComponent = MyGarageWindowComponent()
        self.editProfileWindowComponent = EditProfileWindowComponent()
        self.changePasswordWindowComponent = ChangePasswordWindowComponent()
    }
    
    func makeControllers() {
        self.userStateController = UserStateController(
            apiClient: self.apiClient,
            viewController: self.viewController
        )
        self.signUpController = SignUpController(
            signUpWindowComponent: self.signUpWindowComponent,
            apiClient: self.apiClient
        )
        self.loginController = LoginController(
            loginWindowComponent: self.loginWindowComponent,
            apiClient: self.apiClient
        )
        
        self.meController = MeController(
            profileWindowComponent: self.profileWindowComponent,
            myGarageWindowComponent: self.myGarageWindowComponent,
            editProfileWindowComponent: self.editProfileWindowComponent,
            changePasswordWindowComponent: self.changePasswordWindowComponent,
            parentView: self.parentView,
            apiClient: self.apiClient
        )

    }
    
    func injectControllers(informerController: InformerController, myRecentRacesController: InsightController) {
        self.meController.userStateController = self.userStateController
        self.loginController.userStateController = self.userStateController

        self.meController.myRecentRacesController = myRecentRacesController
        self.meController.informerController = informerController
        
        self.userStateController.informerController = informerController
        self.loginController.informerController = informerController
        self.signUpController.informerController = informerController
    }

    
    func render() {}
}
