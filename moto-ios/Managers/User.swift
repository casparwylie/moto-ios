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
            x: getCenterX(width: self.inputWidth), y: 0, width: self.inputWidth, height: uiDef().ROW_HEIGHT
        )
        
        self.usernameIn = TextField().make(text: "Username...")
        self.usernameIn.frame = inputFrame
        
        self.emailIn = TextField().make(text: "Email...")
        self.emailIn.frame = inputFrame
        
        self.passwordIn = TextField().make(text: "Password...")
        self.passwordIn.frame = inputFrame
        self.passwordIn.isSecureTextEntry = true
        
        self.vpasswordIn = TextField().make(text: "Verify Password...")
        self.vpasswordIn.frame = inputFrame
        self.vpasswordIn.isSecureTextEntry = true
        
        self.submitButton = Button().make(text: "Sign Up", background: .black, color: .white)
        self.submitButton.frame = CGRect(
            x: getCenterX(width: self.inputWidth), y: 0, width: self.inputWidth / 3, height: uiDef().ROW_HEIGHT
        )
        self.submitButton.addTarget(self, action: #selector(self.onSubmitPress), for: .touchDown)
        
        _ = expandDown(
            views: [self.usernameIn, self.emailIn, self.passwordIn, self.vpasswordIn, self.submitButton],
            startY: CGFloat(Self.headerOffset)
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
        super.render(parentView: parentView)
        self.view.addSubview(self.usernameIn)
        self.view.addSubview(self.emailIn)
        self.view.addSubview(self.passwordIn)
        self.view.addSubview(self.vpasswordIn)
        self.view.addSubview(self.submitButton)
    }
}

class LoginWindowComponent: WindowComponent {
    
    var usernameIn: UITextField!
    var passwordIn: UITextField!
    var submitButton: UIButton!
    var toggleForgotPasswordButton: UIButton!
    
    let inputWidth = Int(Double(global_width) * 0.6)
    let inputHeight = uiDef().ROW_HEIGHT
    let inputSpacing = 2

    
    var loginController: LoginController?
    
    var forgotPasswordToggled = false
    let forgotPasswordText = "Forgot Password?"
    let usernamePlaceholderText = "Username..."
    
    
    override func setWindowMeta() {
        self.title = "Login"
    }
    
    func reset() {
        self.usernameIn.text = ""
        self.passwordIn.text = ""
    }
    
    @objc func toggleForgotPassword() {
        self.usernameIn.text = ""
        self.forgotPasswordToggled = !self.forgotPasswordToggled
        if self.forgotPasswordToggled {
            hide(view: self.passwordIn)
            self.usernameIn.placeholder = "Email..."
            self.submitButton.setTitle("Send me a link", for: .normal)
            self.toggleForgotPasswordButton.setTitle("Back to login", for: .normal)
            self.usernameIn.frame.origin.y += CGFloat(self.inputHeight + self.inputSpacing)
        } else {
            show(view: self.passwordIn)
            self.usernameIn.placeholder = self.usernamePlaceholderText
            self.submitButton.setTitle("Login", for: .normal)
            self.toggleForgotPasswordButton.setTitle(self.forgotPasswordText, for: .normal)
            self.usernameIn.frame.origin.y -= CGFloat(self.inputHeight + self.inputSpacing)

        }
    }
    
    func renderInputs() {
        let inputFrame = CGRect(
            x: getCenterX(width: self.inputWidth), y: 0, width: self.inputWidth, height: self.inputHeight
        )

        self.usernameIn = TextField().make(text: self.usernamePlaceholderText)
        self.usernameIn.frame = inputFrame

        self.passwordIn = TextField().make(text: "Password...")
        self.passwordIn.frame = inputFrame
        self.passwordIn.isSecureTextEntry = true

        self.submitButton = Button().make(text: "Login", background: .black, color: .white)
        self.submitButton.frame = CGRect(
            x: getCenterX(width: self.inputWidth), y: 0, width: self.inputWidth / 3, height: self.inputHeight
        )
        self.submitButton.addTarget(self, action: #selector(self.onSubmitPress), for: .touchDown)
        
        _ = expandDown(
            views: [self.usernameIn, self.passwordIn, self.submitButton],
            startY: CGFloat(Self.headerOffset),
            spacing: CGFloat(self.inputSpacing)
        )
        
        
        self.toggleForgotPasswordButton = Button().make(text: self.forgotPasswordText)
        self.toggleForgotPasswordButton.addTarget(self, action: #selector(self.toggleForgotPassword), for: .touchDown)
        self.toggleForgotPasswordButton.frame = self.submitButton.frame
        self.toggleForgotPasswordButton.frame.origin.x += self.submitButton.frame.width + 5
        
        self.view.addSubview(self.usernameIn)
        self.view.addSubview(self.passwordIn)
        self.view.addSubview(self.submitButton)
        self.view.addSubview(self.toggleForgotPasswordButton)
    }
    
    @MainActor @objc func onSubmitPress() {
        if self.forgotPasswordToggled {
            self.loginController?.forgotPassword(email: self.usernameIn.text!)
        } else {
            self.loginController?.loginUser(
                username: self.usernameIn.text!,
                password: self.passwordIn.text!
            )
        }
    }
    
    override func render(parentView: UIView) {
        super.render(parentView: parentView)
        self.renderInputs()
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
        self.signUpWindowComponent.startLoading()
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
            self.signUpWindowComponent.stopLoading()
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
        self.loginWindowComponent.startLoading()
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
                    self.informerController?.inform(
                        message: "Incorrect username or password.", mood: "bad"
                    )
                }
            }
            self.loginWindowComponent.stopLoading()
        }
    }
    
    @MainActor func forgotPassword(email: String) {
        Task {
            if let response = await self.apiClient.forgotPassword(email: email) {
                if response.success {
                    self.informerController?.inform(
                        message: "You have been sent an email to reset your password.", mood: "good"
                    )
                    self.loginWindowComponent.toggleForgotPassword()
                } else {
                    self.informerController?.inform(message: response.errors[0], mood: "bad")
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
    
    @MainActor func logoutUser(message: String = "Successfully logged out!") {
        Task {
            _ = await self.apiClient.logoutUser()
            await self.setUser()
            self.viewController.renderAll(isLoggedin: self.isLoggedin())
            self.informerController?.inform(message: message)
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
        self.button = Button().make(text: self.name, background: .black, color: .white)
        self.button.frame = CGRect(x: 0, y: 0, width: global_width / 5, height: uiDef().ROW_HEIGHT * 2)
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


class DeleteGarageItemButton: Button {
    var modelId: Int?
}

class MyGarageWindowComponent: WindowComponent {
    var meController: MeController?
    var myGarageController: MyGarageController?
    
    var racerInputComponent: RacerInputComponent!
    var racerRecommenderComponent: RacerRecommenderComponent!
    var relationDropDownComponent: DropDownComponent!
    
    var garageView: UIView!
    var garageListingView: UIScrollView!
    var submitButton: UIButton!
    
    let inputSpacing = 2
    let inputHeight = uiDef().ROW_HEIGHT
    let garageItemDeleteButtonSize = uiDef().ROW_HEIGHT
    
    let garageViewWidth = Int(CGFloat(global_width) * 0.8)
    let garageListingViewWidth = Int(CGFloat(global_width) * 0.8)
    let garageViewHeight = global_height
    let garageListingViewY = uiDef().ROW_HEIGHT * 3
    let garageListingViewHeight = uiDef().ROW_HEIGHT + 10
    let garageListingViewMaxHeight = 150
    
    var addGarageCurrentRelationId: String = ""
    
    var garageListingLabels: [UILabel] = []
    
    var noGarageItemsLabel: UILabel!
    
    let garageItemRelationMap = [
        "Once sat on": "SAT_ON",
        "Currently own": "OWNS",
        "Used to own": "HAS_OWNED",
        "Have ridden": "HAS_RIDDEN"
    ]
    
    override init () {
        self.racerInputComponent = RacerInputComponent()
        self.racerRecommenderComponent = RacerRecommenderComponent()
        self.relationDropDownComponent = DropDownComponent()
    }
    
    override func setWindowMeta() {
        self.title = "Me > My Garage"
    }
    
    
    func makeGarageView() {
        self.garageView = UIView(
            frame: CGRect(
                x: getCenterX(width: self.garageViewWidth),
                y:  Self.headerOffset,
                width: self.garageViewWidth,
                height: self.garageViewHeight
            )
        )
    }
    
    func makeGarageListingView() {
        self.garageListingView = UIScrollView(
            frame: CGRect(
                x:  0,
                y: garageListingViewY,
                width: self.garageListingViewWidth,
                height: self.garageListingViewHeight
            )
        )
        self.garageListingView.layer.borderWidth = 3
        self.garageListingView.layer.borderColor = UIColor.black.cgColor
    }
    
    @MainActor func populateGarageItems(items: [GarageItemModel]) {
        self.clearGarageListing()
        if items.count == 0 {
            self.garageListingView.addSubview(self.noGarageItemsLabel)
            self.garageListingView.frame.size.height = CGFloat(self.garageListingViewHeight)
            return
        }
        self.startLoading()
        var rows: [UILabel] = []
        var deleteButtons: [UIButton] = []
        for item in items {
            let relation = Array(
                self.garageItemRelationMap.keys
            )[Array(self.garageItemRelationMap.values).firstIndex(of: item.relation)!]
            let row = Label().make(text: "\(item.make_name) \(item.name) - \(relation)", align: .center)
            row.frame = CGRect(x: 0, y: 0, width: self.garageListingViewWidth, height: self.inputHeight)
            rows.append(row)
            let deleteButton = self.makeDeleteGarageItemOption(modelId: item.model_id)
            deleteButtons.append(deleteButton)
            self.garageListingView.addSubview(row)
            self.garageListingView.addSubview(deleteButton)
        }
        let lastY = expandDown(views: rows)
        _ = expandDown(views: deleteButtons)
        self.updateListingFrame(lastY: Int(lastY))
        self.stopLoading()

    }
    
    func updateListingFrame(lastY: Int) {
        self.garageListingView.frame.size.height = CGFloat(
            (lastY > self.garageListingViewMaxHeight) ? self.garageListingViewMaxHeight : lastY
        )
        self.garageListingView.contentSize = (
            CGSize(width: self.garageListingViewWidth, height: lastY)
        )
    }
    
    func makeNoGarageItemsLabel() {
        self.noGarageItemsLabel = Label().make(
            text: "Your garage is empty. Add bikes now so others can see what you ride. ",
            align: .center
        )
        self.noGarageItemsLabel.frame = CGRect(
            x: getCenterX(width: global_width),
            y: 10,
            width: self.garageListingViewWidth,
            height: self.inputHeight
        )
    }
    
    func makeDeleteGarageItemOption(modelId: Int?) -> UIButton {
        let deleteButton = DeleteGarageItemButton().make(text: "✕", color: _RED) as! DeleteGarageItemButton
        deleteButton.modelId = modelId
        deleteButton.frame = CGRect(
            x: self.garageListingViewWidth - self.garageItemDeleteButtonSize,
            y: 0,
            width: self.garageItemDeleteButtonSize,
            height: self.garageItemDeleteButtonSize
        )
        deleteButton.addTarget(self, action: #selector(self.onDeleteGarageItemPress), for: .touchDown)
        return deleteButton
    }
    
    @MainActor @objc func onDeleteGarageItemPress(deleteButton: DeleteGarageItemButton) {
        if let modelId = deleteButton.modelId {
            self.myGarageController?.deleteGarageItem(model_id: modelId)
        }
    }
    
    @MainActor func clearGarageListing() {
        self.garageListingView.subviews.forEach{subview in subview.removeFromSuperview()}
        self.garageListingLabels = []
        
    }
    
    func resetAddInputs() {
        self.racerInputComponent.reset()
        self.relationDropDownComponent.close()
    }

    func makeAddGarageInputs() {
        let width: Int = (self.garageViewWidth / 2) - (self.inputSpacing / 2)
        let y = self.inputHeight + self.inputSpacing
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeDropDown))
        self.view.addGestureRecognizer(tap)

        self.relationDropDownComponent.listingComponent.rowBorderColor = .white
        self.relationDropDownComponent.listingComponent.view.backgroundColor = .black
        self.relationDropDownComponent.setTitle(title: "Select Relationship")
        self.relationDropDownComponent.setFrame(
            frame: CGRect(x: 0, y: y, width: width, height: self.inputHeight)
        )
        self.garageItemRelationMap.keys.forEach {
            value in self.relationDropDownComponent.addRow(text: value) {}
        }
        self.submitButton = Button().make(
            text: "Add", background: .black, color: .white
        )
        self.submitButton.frame = CGRect(
            x: width + self.inputSpacing, y: y, width: width, height: self.inputHeight
        )
        self.submitButton.addTarget(self, action: #selector(self.onSubmitPress), for: .touchDown)
    }
    
    @objc func closeDropDown() {
        self.relationDropDownComponent.close()
    }
 
    
    @MainActor @objc func onSubmitPress () {
        if let relationId = self.garageItemRelationMap[self.relationDropDownComponent.getLastSelectedText()] {
            if let partialRacer = self.racerInputComponent.getPartialRacerFromInputs() {
                self.myGarageController?.addGarageItem(
                    racer: partialRacer,
                    relationId: relationId
                )
                self.resetAddInputs()
            }
        }
    }

    override func render(parentView: UIView) {
        super.render(parentView: parentView)
        self.makeGarageView()
        self.makeGarageListingView()
        
        self.garageView.addSubview(self.garageListingView)
        self.view.addSubview(self.garageView)
        
        self.makeNoGarageItemsLabel()
        
        self.relationDropDownComponent.render(parentView: self.garageView)
        self.relationDropDownComponent.view.layer.zPosition = 1
        self.racerInputComponent.render(parentView: self.garageView)

        self.makeAddGarageInputs()
        self.garageView.addSubview(self.submitButton)
        self.racerRecommenderComponent.render(parentView: self.view)
        
        self.myGarageController?.populateGarageItems()
    }
 
}

class MyGarageController {
    var myGarageWindowComponent: MyGarageWindowComponent!
    var apiClient: UserApiClient!
    var informerController: InformerController?
    
    var meController: MeController?
    
    init(myGarageWindowComponent: MyGarageWindowComponent, apiClient: UserApiClient) {
        self.myGarageWindowComponent = myGarageWindowComponent
        self.apiClient = apiClient
        self.myGarageWindowComponent.myGarageController = self
    }
    
    @MainActor func addGarageItem(racer: PartialRacer, relationId: String) {
        self.myGarageWindowComponent.startLoading()
        Task {
            if let response = await self.apiClient.addGarageItem(racer: racer, relation: relationId) {
                if response.success {
                    informerController?.inform(message: "Successfully added!")
                    self.populateGarageItems()
                } else {
                    self.informerController?.inform(message: response.errors[0], mood: "bad")
                }
            }
            self.myGarageWindowComponent.stopLoading()
        }
    }
    
    @MainActor func deleteGarageItem(model_id: Int) {
        Task {
            if let response = await self.apiClient.deleteGarageItem(model_id: model_id) {
                if response.success { // TODO: The following pattern is repeated a lot. Consider base controller logic.
                    informerController?.inform(message: "Successfully deleted!")
                    self.populateGarageItems()
                } else {
                    self.informerController?.inform(message: response.errors[0], mood: "bad")
                }
            }
        }
    }
    
    func populateGarageItems() {
        Task {
            if let response = await self.apiClient.getGarageItems(userId: (self.meController?.currentUserId)!) {
                await self.myGarageWindowComponent.populateGarageItems(items: response.items)
            }
        }
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
            x: getCenterX(width: self.inputWidth), y: 0, width: self.inputWidth, height: uiDef().ROW_HEIGHT
        )
        self.oldPasswordIn = TextField().make(text: "Current Password...")
        self.oldPasswordIn.frame = inputFrame
        self.oldPasswordIn.isSecureTextEntry = true
        
        self.newPasswordIn = TextField().make(text: "New Password...")
        self.newPasswordIn.frame = inputFrame
        self.newPasswordIn.isSecureTextEntry = true
        
        self.vPasswordIn = TextField().make(text: "Verify Password...")
        self.vPasswordIn.frame = inputFrame
        self.vPasswordIn.isSecureTextEntry = true
        
        self.submitButton = Button().make(text: "Change", background: .black, color: .white)
        self.submitButton.frame = inputFrame
        self.submitButton.frame.size.width = CGFloat(self.inputWidth / 3)
        self.submitButton.addTarget(self, action: #selector(self.onSubmitPress), for: .touchDown)
        
        _ = expandDown(
            views: [self.oldPasswordIn, self.newPasswordIn, self.vPasswordIn, self.submitButton],
            startY: CGFloat(Self.headerOffset)
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
    
    var submitUsernameButton: UIButton!
    var submitEmailButton: UIButton!
    var deleteAccountButton: UIButton!

    var editUsernameIn: UITextField!
    var editEmailIn: UITextField!
    
    let deleteAccountButtonWidth = global_width / 3
    var inputWidth = Int(Double(global_width) * 0.5)
    var submitButtonWidth = Int(Double(global_width) * 0.1)
    var submitSpacing = 5

    
    override func setWindowMeta() {
        self.title = "Me > Edit Account"
    }
    
    func makeEditInputs() {
        let centerX = getCenterX(width: self.inputWidth + self.submitButtonWidth + self.submitSpacing)
        let inputFrame = CGRect(
            x: centerX, y: 0, width: self.inputWidth, height: uiDef().ROW_HEIGHT
        )
        let submitFrame = CGRect(
            x: centerX + self.inputWidth + self.submitSpacing,
            y: 0,
            width: self.submitButtonWidth,
            height: uiDef().ROW_HEIGHT
        )
        self.editUsernameIn = TextField().make(text: "New username...")
        self.editUsernameIn.frame = inputFrame
        
        self.editEmailIn = TextField().make(text: "New email...")
        self.editEmailIn.frame = inputFrame
        
        self.submitUsernameButton = Button().make(text: "Save", background: .black, color: .white)
        self.submitUsernameButton.frame = submitFrame
        self.submitUsernameButton.addTarget(self, action: #selector(self.onUsernameSubmitPress), for: .touchDown)
        
        self.submitEmailButton = Button().make(text: "Save", background: .black, color: .white)
        self.submitEmailButton.frame = submitFrame
        self.submitEmailButton.addTarget(self, action: #selector(self.onEmailSubmitPress), for: .touchDown)
        
        _ = expandDown(
            views: [self.editUsernameIn, self.editEmailIn],
            startY: CGFloat(Self.headerOffset)
        )
        
        let lastY = expandDown(
            views: [self.submitUsernameButton, self.submitEmailButton],
            startY: CGFloat(Self.headerOffset)
        )
        
        self.deleteAccountButton = Button().make(text: "Keep tapping to delete account", background: _RED, color: .white)
        self.deleteAccountButton.frame = CGRect(
            x: getCenterX(width: self.deleteAccountButtonWidth),
            y: Int(lastY) + uiDef().ROW_HEIGHT,
            width: self.deleteAccountButtonWidth,
            height: uiDef().ROW_HEIGHT
        )
        self.deleteAccountButton.addTarget(self, action: #selector(self.onDeleteAccountPress), for: .touchDownRepeat)
    }
    
    @MainActor @objc func onDeleteAccountPress() {
        self.meController?.deleteAccount()
    }

    
    @MainActor @objc func onEmailSubmitPress() {
        self.meController?.editUser(field: "email", value: self.editEmailIn.text!)
        self.editEmailIn.text = ""
    }
    
    @MainActor @objc func onUsernameSubmitPress() {
        self.meController?.editUser(field: "username", value: self.editUsernameIn.text!)
        self.editUsernameIn.text = ""
    }
    
    override func render(parentView: UIView) {
        super.render(parentView: parentView)
        self.makeEditInputs()
        self.view.addSubview(self.editUsernameIn)
        self.view.addSubview(self.editEmailIn)
        self.view.addSubview(self.submitUsernameButton)
        self.view.addSubview(self.submitEmailButton)
        self.view.addSubview(self.deleteAccountButton)
    }

}


class ProfileWindowComponent: WindowComponent {
    
    var meController: MeController?
    
    var tabButtonComponents: [ProfileTabButtonComponent] = []
    
    var tabButtonView: UIView!
    var userInfoLabel: UILabel!
    
    let userInfoHeight = uiDef().ROW_HEIGHT * 2
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
                name: "Edit Account",
                targetWindow: self.meController?.editProfileWindowComponent
            )
        ]
    }
    
    func makeUserInfo() {
        let email = (self.meController?.userStateController?.currentUser?.email)!
        let username = (self.meController?.userStateController?.currentUser?.username)!
        let infoText = "Email: \(email) \n Username: \(username)"
        self.userInfoLabel = Label().make(text: infoText, align: .center)
        self.userInfoLabel.numberOfLines = 0
        self.userInfoLabel.lineBreakMode = .byWordWrapping
        self.userInfoLabel.frame = CGRect(
            x: getCenterX(width: global_width),
            y: Self.headerOffset,
            width: global_width,
            height: self.userInfoHeight
        )
    }
    
    func makeTabButtons() {
        self.tabButtonView = UIView(
            frame: CGRect(
                x: 0,
                y: Self.headerOffset + self.userInfoHeight + 20,
                width: 0,
                height: self.tabButtonsHeight
            )
        )
        for tabButtonComponent in self.tabButtonComponents {
            tabButtonComponent.render(parentView: self.tabButtonView)
            self.tabButtonView.addSubview(tabButtonComponent.button)
            tabButtonComponent.meController = self.meController
        }
        let lastX = expandAcross(views: self.tabButtonComponents.map{ $0.button })
        self.tabButtonView.frame.size.width = lastX
        self.tabButtonView.frame.origin.x = CGFloat(getCenterX(width: Int(lastX)))
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
    
    var currentUserId: Int?

    
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
        self.editProfileWindowComponent.meController = self
        self.changePasswordWindowComponent.meController = self

    }
    
    func setUser() {
        if let userId = self.userStateController?.currentUser?.user_id {
            self.currentUserId = userId
            self.myRecentRacesController?.apiFlags = ["user_id": String(userId)]
        }
    }
    
    @MainActor func changePassword(oldPassword: String, newPassword: String, vPassword: String) {
        if (oldPassword.count > 0 && newPassword.count > 0 && vPassword.count > 0) {
            if (newPassword == vPassword) {
                self.changePasswordWindowComponent.startLoading()
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
                    self.changePasswordWindowComponent.stopLoading()
                }
            } else {
                self.informerController?.inform(message: "Passwords do not match.", mood: "bad")
            }
        }
    }
    
    @MainActor func editUser(field: String, value: String) {
        if value.count > 0 {
            self.editProfileWindowComponent.startLoading()
            Task {
                if let response = await self.apiClient.editFieldUser(field: field, value: value) {
                    if response.errors.count > 0 {
                        self.informerController?.inform(message: response.errors[0], mood: "bad")
                    } else {
                        await self.userStateController?.setUser()
                        self.editProfileWindowComponent.view.removeFromSuperview()
                        self.profileWindowComponent.render(parentView: self.parentView)
                        self.informerController?.inform(message: "Successfully saved!")
                    }
                }
                self.editProfileWindowComponent.stopLoading()
            }
        }
    }
    
    @MainActor func deleteAccount() {
        Task {
            if let response = await self.apiClient.deleteAccount() {
                if response.errors.count > 0 {
                    self.informerController?.inform(message: response.errors[0], mood: "bad")
                } else {
                    await self.userStateController?.logoutUser(message: "Successfully deleted account!")
                }
            }
            self.editProfileWindowComponent.stopLoading()
        }
    }
}


class UserManager {
    var apiClient: UserApiClient!
    var racingApiClient: RacingApiClient!
    
    var parentView: UIView!
    var informerController: InformerController?
    var myRecentRacesController: InsightController!
    var viewController: ViewController!
    var racerRecommendingController: RacerRecommendingController!
    
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
    var myGarageController: MyGarageController!
    
    
    init(
        apiClient: UserApiClient,
        racingApiClient: RacingApiClient,
        viewController: ViewController
    ) {
        self.apiClient = apiClient
        self.racingApiClient = racingApiClient
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
        self.racerRecommendingController = RacerRecommendingController(
            apiClient: self.racingApiClient,
            recommenderComponent: self.myGarageWindowComponent.racerRecommenderComponent,
            raceInputOwner: self.myGarageWindowComponent.racerInputComponent
        )

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
        self.myGarageController = MyGarageController(
            myGarageWindowComponent: self.myGarageWindowComponent,
            apiClient: self.apiClient
        )
    }
    
    func injectControllers(
        informerController: InformerController,
        myRecentRacesController: InsightController,
        racerRecommendingController: RacerRecommendingController
    ) {
        self.loginController.informerController = informerController
        self.loginController.userStateController = self.userStateController

        self.meController.userStateController = self.userStateController
        self.meController.myRecentRacesController = myRecentRacesController
        self.meController.informerController = informerController
        
        self.userStateController.informerController = informerController
        self.signUpController.informerController = informerController
        
        self.myGarageController.informerController = informerController
        self.myGarageController.meController = self.meController
        
    }

    
    func render() {}
}
