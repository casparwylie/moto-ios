//
//  SocialClient.swift
//  moto-ios
//
//  Created by Caspar Wylie on 05/04/2023.
//

import Foundation

struct CommentModel: Decodable {
    var id: Int?
    var text: String?
    var username: String?
    var race_unique_id: String?
    var created_at: String?
    var garage_relation_sentence: String?
}

struct CommentsResponseModel: Decodable {
    var comments: [CommentModel]
}

struct AddCommentRequestModel: Codable {
    var race_unique_id: String?
    var text: String?
}

struct DeleteCommentRequestModel: Codable {
    var comment_id: Int?
}


class SocialApiClient: BaseApiClient {
    func getRaceComments(uniqueRaceId: String) async -> CommentsResponseModel? {
        return await self._make_get_request(
            path: "/comments",
            queryItems:  [URLQueryItem(name: "race_unique_id", value: uniqueRaceId)],
            responseModel: CommentsResponseModel.self
        )
    }
    
    func addComment(uniqueRaceId: String, text: String) async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/add-comment",
            body: AddCommentRequestModel(race_unique_id: uniqueRaceId, text: text),
            responseModel: SuccessResponseModel.self
        )
    }
    
    func deleteComment(commentId: Int) async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/delete-comment",
            body: DeleteCommentRequestModel(comment_id: commentId),
            responseModel: SuccessResponseModel.self
        )
    }
}
