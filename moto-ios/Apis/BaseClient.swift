//
//  Api.swift
//  moto-ios
//
//  Created by Caspar Wylie on 13/03/2023.
//
import UIKit


struct SuccessResponseModel: Decodable {
    var success: Bool
    var errors: [String]
}

class BaseApiClient {
    var base_url: String!
    init (base_url: String) {
        self.base_url = base_url
    }
    
    func _make_get_request<ResponseModel: Decodable> (
        path: String, queryItems: [URLQueryItem], responseModel: ResponseModel.Type
    ) async -> ResponseModel? {
        var url = URLComponents(url: URL(string: self.base_url + path)!, resolvingAgainstBaseURL: true)!
        url.queryItems = queryItems
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        if let (data, _)  = try? await URLSession.shared.data(for: request) {
            return try? JSONDecoder().decode(responseModel, from: data)
        }
        return nil
    }
    
    func _make_post_request<ResponseModel: Decodable> (
        path: String, body: Codable, responseModel: ResponseModel.Type
    ) async -> ResponseModel? {
        let url = URL(string: base_url + path)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(body)
        if let (data, _)  = try? await URLSession.shared.data(for: request) {
            return try? JSONDecoder().decode(responseModel, from: data)
        }
        return nil
    }
}
