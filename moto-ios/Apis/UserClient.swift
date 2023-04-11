//
//  UserClient.swift
//  moto-ios
//
//  Created by Caspar Wylie on 30/03/2023.
//

import Foundation



struct SignupRequestModel: Codable {
    var username: String
    var email: String
    var password: String
}

struct SignupResponseModel: Decodable {
    var success: Bool
    var errors: [String]
}

struct LoginRequestModel: Codable {
    var username: String
    var password: String
}

struct UserResponseModel: Decodable {
    var user_id: Int
    var username: String
    var email: String
}

struct ChangePasswordRequestModel: Codable {
    var old: String
    var new: String
}


class UserApiClient: BaseApiClient {

    func signupUser(username: String, email: String, password: String) async -> SignupResponseModel? {
         let request = SignupRequestModel(username: username, email: email, password: password)
         return await self._make_post_request(
             path: "/signup", body: request, responseModel: SignupResponseModel.self
         )
    }
    
    func loginUser(username: String, password: String) async -> SuccessResponseModel? {
         let request = LoginRequestModel(username: username, password: password)
         return await self._make_post_request(
             path: "/login", body: request, responseModel: SuccessResponseModel.self
         )
    }
    
    func getUser() async -> UserResponseModel? {
        return await self._make_get_request(
            path: "", queryItems: [], responseModel: UserResponseModel.self
        )
    }
    
    func logoutUser() async -> SuccessResponseModel? {
        return await self._make_get_request(
            path: "/logout", queryItems: [], responseModel: SuccessResponseModel.self
        )
    }
    
    func changePassword(oldPassword: String, newPassword: String) async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/change-password",
            body: ChangePasswordRequestModel(old: oldPassword, new: newPassword),
            responseModel: SuccessResponseModel.self
        )
    }
    
}
