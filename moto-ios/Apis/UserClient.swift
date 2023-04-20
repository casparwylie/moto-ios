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


struct EditUserFieldRequestModel: Codable {
    var field: String
    var value: String
}


struct GarageItemModel: Codable {
    var relation: String
    var name: String
    var make_name: String
    var year: Int //TODO: Make String on server
    var model_id: Int?
}

struct UserGarageResponseModel: Decodable {
    var items: [GarageItemModel]
}


struct DeleteGarageItemRequestModel: Codable {
    var model_id: Int
}


struct ForgotPasswordRequestModel: Codable {
    var email: String
}

struct DeleteAccountRequestModel: Codable {
    
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
    
    func editFieldUser(field: String, value: String) async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/edit",
            body: EditUserFieldRequestModel(field: field, value: value),
            responseModel: SuccessResponseModel.self
        )
    }
    
    func addGarageItem(racer: PartialRacer, relation: String) async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/garage",
            body: GarageItemModel(
                relation: relation, name: racer.model, make_name: racer.make, year: Int(racer.year)!
            ),
            responseModel: SuccessResponseModel.self
        )
    }
    
    func deleteGarageItem(model_id: Int)  async -> SuccessResponseModel?  {
        return await self._make_post_request(
            path: "/garage/delete",
            body: DeleteGarageItemRequestModel(model_id: model_id),
            responseModel: SuccessResponseModel.self
        )
    }
    
    
    func getGarageItems(userId: Int) async -> UserGarageResponseModel? {
        return await self._make_get_request(
            path: "/garage",
            queryItems:  [URLQueryItem(name: "user_id", value: String(userId))],
            responseModel: UserGarageResponseModel.self
        )
    }
    
    func forgotPassword(email: String) async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/forgot-password",
            body: ForgotPasswordRequestModel(email: email),
            responseModel: SuccessResponseModel.self
        )
    }
    
    func deleteAccount()  async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/delete",
            body: DeleteAccountRequestModel(),
            responseModel: SuccessResponseModel.self
        )
    }
    
}
