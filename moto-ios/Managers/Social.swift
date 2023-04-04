//
//  Social.swift
//  moto-ios
//
//  Created by Caspar Wylie on 05/04/2023.
//

import Foundation
import UIKit

class CommentComponent {
    var commentsController: CommentsController?

    var comment: CommentModel!
    var view: UIView!
    let width = Int(Double(global_width) * 0.7)
    
    var mainLabel: UILabel!
    var mainInfo: UIView!
    var deleteButton: UIButton?
    
    let infoHeight: CGFloat = 40
    let topPadding: CGFloat = 10
    let infoLineSpacing = 10
    let deleteButtonSize = 15

    init(comment: CommentModel) {
        self.comment = comment
    }
    
    func makeTextLabel() {
        self.mainLabel = _make_text(text: self.comment.text!, align: .center)
        self.mainLabel.numberOfLines = 0
        self.mainLabel.lineBreakMode = .byWordWrapping
        self.mainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mainLabel.frame = CGRect(
            x: 0,
            y: Int(self.topPadding),
            width: self.width,
            height: 0
        )
        self.mainLabel.sizeToFit()
        self.mainLabel.frame.size.width = CGFloat(self.width)
        self.view.frame.size.height = self.mainLabel.frame.size.height + self.topPadding + self.infoHeight
    }
    
    func makeInfo() {
        self.mainInfo = UIView(
            frame: CGRect(
                x: 0,
                y: self.mainLabel.frame.size.height,
                width: CGFloat(self.width),
                height: self.infoHeight
            )
        )
        
        let infoLabel = _make_text(
            text: "- \(self.comment.username!) | \(self.comment.created_at!)",
            align: .center,
            size: 12,
            color: _DARK2_TBLUE
        )
        infoLabel.frame = CGRect(
            x: 0,
            y: self.infoLineSpacing,
            width: self.width,
            height: Int(self.infoHeight / 2)
        )
        self.mainInfo.addSubview(infoLabel)
        
        if let relationString = self.comment.garage_relation_sentence {
            if relationString.count > 0 {
                let relationLabel = _make_text(
                    text: "* \(relationString)",
                    align: .center,
                    size: 12,
                    color: .white
                )
                relationLabel.frame = CGRect(
                    x: 0,
                    y: self.infoLineSpacing + (Int(self.infoHeight) / 2),
                    width: self.width,
                    height: Int(self.infoHeight / 2)
                )
                self.mainInfo.addSubview(relationLabel)
            }
        }
    }
    
    func makeDeleteButton() {
        if (self.commentsController?.userStateController.isLoggedin() ?? false && self.commentsController?.userStateController.currentUser?.username == self.comment.username
        ) {
            self.deleteButton = _make_button(text: "✕", color: _RED, size: self.deleteButtonSize)
            self.deleteButton!.frame = CGRect(
                x: Int(self.width - deleteButtonSize),
                y: 0,
                width: self.deleteButtonSize,
                height: self.deleteButtonSize
            )
            self.deleteButton!.addTarget(self, action: #selector(onDeletePress), for: .touchDown)
        }
    }
    
    @MainActor @objc func onDeletePress() {
        if let commentId = self.comment.id {
            self.commentsController?.deleteComment(commentId: commentId)
        }
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 0,
                width: self.width,
                height: 0
            )
        )
        self.view.layer.cornerRadius = _DEFAULT_CORNER_RADIUS
        self.view.backgroundColor = _DARK_TBLUE
        
        self.makeTextLabel()
        self.makeInfo()
        self.makeDeleteButton()
        self.view.addSubview(self.mainLabel)
        self.view.addSubview(self.mainInfo)
        if let deleteButton = self.deleteButton {
            self.view.addSubview(deleteButton)
        }
        parentView.addSubview(self.view)
    }
}


class CommentsWindowComponent: WindowComponent {
    var informer: InformerManager!
    
    var commentsController: CommentsController?

    var commentComponents: [CommentComponent] = []
    var commentTextBox: UITextView!
    let commentTextBoxSpacing: CGFloat = 5
    let commentTextBoxWidth = Int(Double(global_width) * 0.7)
    let commentTextBoxHeight = 100

    
    var commentButton: UIButton!
    let commentButtonWidth = Int(Double(global_width) * 0.3)
    let commentButtonHeight = 30

        
    init(informer: InformerManager) {
        super.init()
        self.informer = informer
    }

    override func setWindowMeta() {
        self.title = "Comments"
    }
    
    @MainActor func populateComments(comments: [CommentModel]) {
        self.commentComponents.forEach{ component in component.view.removeFromSuperview() }
        self.commentComponents = []
        self.commentTextBox.text = ""
        for comment in comments {
            let commentComponent = CommentComponent(comment: comment)
            commentComponent.commentsController = self.commentsController
            self.commentComponents.append(commentComponent)
            commentComponent.render(parentView: self.view)
        }
        let lastY = _expand_as_list(
            views: self.commentComponents.map{ $0.view }, startY: CGFloat(self.titleHeight)
        )
        self.updateFrames(lastY: lastY)
    }
    
    func updateFrames(lastY: CGFloat) {
        self.commentTextBox.frame.origin.y = lastY + self.commentTextBoxSpacing
        self.commentButton.frame.origin.y = (
            lastY
            + self.commentTextBox.frame.height
            + self.commentTextBoxSpacing * 2
        )
        self.view.contentSize = CGSize(
            width: CGFloat(global_width),
            height: (
                CGFloat(lastY)
                + self.commentTextBox.frame.height
                + self.commentButton.frame.height
                + self.commentTextBoxSpacing * 3
            )
        )
    }
    
    func makeCommentBox() {
        self.commentTextBox = _make_text_box_input()
        self.commentTextBox.frame = CGRect(
            x: _get_center_x(width: self.commentTextBoxWidth),
            y: 0,
            width: self.commentTextBoxWidth,
            height: commentTextBoxHeight
        )
    }
    
    func makeCommentButton() {
        self.commentButton = _make_button(text: "Comment", background: .black, color: .white)
        self.commentButton.frame = CGRect(
            x: Int(self.commentTextBox.frame.origin.x),
            y: 0,
            width: self.commentButtonWidth,
            height: self.commentButtonHeight
        )
        self.commentButton.addTarget(self, action: #selector(self.onAddCommentPress), for: .touchDown)
    }
    
    @MainActor @objc func onAddCommentPress() {
        if self.commentTextBox.text.count > 1 {
            commentsController?.addComment(text: self.commentTextBox.text)
        }
    }
    
    func render(parentView: UIView) {
        super.render()
        self.commentsController?.populateComments()
        self.makeCommentBox()
        self.makeCommentButton()
        self.view.addSubview(self.commentTextBox)
        self.view.addSubview(self.commentButton)
        parentView.addSubview(self.view)
    }
}


class CommentsController {
    var mainView: UIView!
    var commentsWindowComponent: CommentsWindowComponent!
    var apiClient: SocialApiClient!
    var informer: InformerManager!
    var userStateController: UserStateController!
    
    var currentUniqueRaceId: String?

    init(
        commentsWindowComponent: CommentsWindowComponent,
        userStateController: UserStateController,
        apiClient: SocialApiClient,
        informer: InformerManager,
        mainView: UIView
    ) {
        self.mainView = mainView
        self.apiClient = apiClient
        self.informer = informer
        self.userStateController = userStateController
        self.commentsWindowComponent = commentsWindowComponent
        self.commentsWindowComponent.commentsController = self
    }
    
    func populateComments() {
        Task {
            if let uniqueRaceId = self.currentUniqueRaceId {
                if let result = await self.apiClient.getRaceComments(uniqueRaceId: uniqueRaceId) {
                    await self.commentsWindowComponent.populateComments(comments: result.comments)
                }
            }
        }
    }
    
    func viewComments(uniqueRaceId: String) {
        self.currentUniqueRaceId = uniqueRaceId
        self.commentsWindowComponent.render(parentView: self.mainView)
    }
    
    @MainActor func addComment(text: String) {
        Task {
            if let uniqueRaceId = self.currentUniqueRaceId {
                if let result = await self.apiClient.addComment(uniqueRaceId: uniqueRaceId, text: text) {
                    if result.success {
                        self.populateComments()
                        self.informer.inform(message: "Successfully commented!")
                    }
                } else {
                    self.informer.inform(message: "You must have an account to comment.", mood: "bad")
                }
            }
        }
    }
    
    @MainActor func deleteComment(commentId: Int) {
        Task {
            if let result = await self.apiClient.deleteComment(commentId: commentId) {
                if result.success {
                    self.populateComments()
                    self.informer.inform(message: "Successfully deleted!")
                }
            }
        }
    }
}

class SocialManager {
    
    var informer: InformerManager!
    var userStateController: UserStateController!
    var apiClient: SocialApiClient!
    var parentView: UIView!
    
    var commentsWindowComponent: CommentsWindowComponent!
    var commentsController: CommentsController!
    
    init(informer: InformerManager, userStateController: UserStateController, apiClient: SocialApiClient, parentView: UIView) {
        
        self.informer = informer
        self.userStateController = userStateController
        self.apiClient = apiClient
        self.parentView = parentView
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents() {
        self.commentsWindowComponent = CommentsWindowComponent(informer: self.informer)
    }
    
    func makeControllers() {
        self.commentsController = CommentsController(
            commentsWindowComponent: self.commentsWindowComponent,
            userStateController: self.userStateController,
            apiClient: self.apiClient,
            informer: self.informer,
            mainView: self.parentView
        )
    }
    
    func render() {
        
    }
}


