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
        self.mainLabel = Label().make(text: self.comment.text!, align: .center)
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
        
        let infoLabel = Label().make(
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
                let relationLabel = Label().make(
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
        if (
            self.commentsController?.userStateController?.isLoggedin() ?? false
            && self.commentsController?.userStateController?.currentUser?.username == self.comment.username
        ) {
            self.deleteButton = Button().make(text: "✕", color: _RED, size: self.deleteButtonSize)
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
                x: getCenterX(width: self.width),
                y: 0,
                width: self.width,
                height: 0
            )
        )
        self.view.layer.cornerRadius = uiDef().CORNER_RADIUS
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
    var commentsController: CommentsController?

    var commentComponents: [CommentComponent] = []
    
    var noCommentsLabel: UILabel!
    
    var commentTextBox: UITextView!
    let commentTextBoxSpacing: CGFloat = 5
    let commentTextBoxWidth = Int(Double(global_width) * 0.7)
    let commentTextBoxHeight = 100

    
    var commentButton: UIButton!
    let commentButtonWidth = Int(Double(global_width) * 0.3)
    let commentButtonHeight = uiDef().ROW_HEIGHT


    override func setWindowMeta() {
        self.title = "Comments"
    }
    
    @MainActor func populateComments(comments: [CommentModel]) {
        self.commentComponents.forEach{ component in component.view.removeFromSuperview() }
        self.commentComponents = []
        self.commentTextBox.text = ""
        self.noCommentsLabel.removeFromSuperview()
        if comments.count > 0 {
            for comment in comments {
                let commentComponent = CommentComponent(comment: comment)
                commentComponent.commentsController = self.commentsController
                self.commentComponents.append(commentComponent)
                commentComponent.render(parentView: self.view)
            }
            let lastY = expandDown(
                views: self.commentComponents.map{ $0.view }, startY: CGFloat(Self.headerOffset)
            )
            self.updateFrames(lastY: lastY)
        } else {
            self.view.addSubview(self.noCommentsLabel)
            self.updateFrames(
                lastY: CGFloat(Self.headerOffset)
                + self.noCommentsLabel.frame.height
                + self.commentTextBoxSpacing
            )
        }
        
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
        self.commentTextBox = TextBox().make()
        self.commentTextBox.frame = CGRect(
            x: getCenterX(width: self.commentTextBoxWidth),
            y: 0,
            width: self.commentTextBoxWidth,
            height: commentTextBoxHeight
        )
    }
    
    func makeCommentButton() {
        self.commentButton = Button().make(text: "Comment", background: .black, color: .white)
        self.commentButton.frame = CGRect(
            x: Int(self.commentTextBox.frame.origin.x),
            y: 0,
            width: self.commentButtonWidth,
            height: self.commentButtonHeight
        )
        self.commentButton.addTarget(self, action: #selector(self.onAddCommentPress), for: .touchDown)
    }
    
    func makeNoCommentsLabel() {
        self.noCommentsLabel = Label().make(text: "There are no comments for this race yet.", align: .center)
        self.noCommentsLabel.frame = CGRect(
            x: getCenterX(width: global_width),
            y: Self.headerOffset,
            width: global_width,
            height: uiDef().ROW_HEIGHT
        )
    }
    
    @MainActor @objc func onAddCommentPress() {
        if self.commentTextBox.text.count > 1 {
            commentsController?.addComment(text: self.commentTextBox.text)
        }
    }
    
    override func render(parentView: UIView) {
        self.makeNoCommentsLabel()
        self.commentsController?.populateComments()
        self.makeCommentBox()
        self.makeCommentButton()
        super.render(parentView: parentView)
        self.view.addSubview(self.commentTextBox)
        self.view.addSubview(self.commentButton)
    }
}


class CommentsController {
    var mainView: UIView!
    var commentsWindowComponent: CommentsWindowComponent!
    var apiClient: SocialApiClient!
    var informerController: InformerController?
    var userStateController: UserStateController?
    
    var currentUniqueRaceId: String?

    init(
        commentsWindowComponent: CommentsWindowComponent,
        apiClient: SocialApiClient,
        mainView: UIView
    ) {
        self.mainView = mainView
        self.apiClient = apiClient
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
        self.commentsWindowComponent.startLoading()
        Task {
            if let uniqueRaceId = self.currentUniqueRaceId {
                if let result = await self.apiClient.addComment(uniqueRaceId: uniqueRaceId, text: text) {
                    if result.success {
                        self.populateComments()
                        self.informerController?.inform(message: "Successfully commented!")
                    } else {
                       self.informerController?.inform(message: result.errors[0], mood: "bad")
                   }
                } else {
                    // TODO: Handle 403 error code explicitly
                    self.informerController?.inform(message: "You must have an account to comment.", mood: "bad")
                }
            }
            self.commentsWindowComponent.stopLoading()
        }
    }
    
    @MainActor func deleteComment(commentId: Int) {
        Task {
            if let result = await self.apiClient.deleteComment(commentId: commentId) {
                if result.success {
                    self.populateComments()
                    self.informerController?.inform(message: "Successfully deleted!")
                }
            }
        }
    }
}

class SocialManager {
    
    var informerController: InformerController?
    var userStateController: UserStateController?
    var apiClient: SocialApiClient!
    var parentView: UIView!
    
    var commentsWindowComponent: CommentsWindowComponent!
    var commentsController: CommentsController!
    
    init(apiClient: SocialApiClient, parentView: UIView) {
        self.apiClient = apiClient
        self.parentView = parentView
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents() {
        self.commentsWindowComponent = CommentsWindowComponent()
    }
    
    func makeControllers() {
        self.commentsController = CommentsController(
            commentsWindowComponent: self.commentsWindowComponent,
            apiClient: self.apiClient,
            mainView: self.parentView
        )
    }
    
    func injectControllers(informerController: InformerController, userStateController: UserStateController) {
        self.commentsController?.userStateController = userStateController
        self.commentsController.informerController = informerController
    }
    
    func render() {
        
    }
}
