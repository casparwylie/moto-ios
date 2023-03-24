//
//  Api.swift
//  moto-ios
//
//  Created by Caspar Wylie on 13/03/2023.
//
import UIKit

struct SignupRequestModel: Codable {
    var username: String
    var email: String
    var password: String
}

struct SignupResponseModel: Decodable {
    var success: Bool
    var errors: [String]
}

struct RacerModel: Decodable {
    var model_id: Int
    var name: String
    var full_name: String
    var make_name: String
    var style: String
    var year: String
    var power: String
    var torque: String
    var weight: String
    var weight_type: String
}


struct RaceModel: Decodable {
    var race_id: Int
    var racers: [RacerModel]
    var user_id: Int?
    var race_unique_id: String
    
}


struct RaceListingModel: Decodable {
    var races: [RaceModel]
}

struct SaveRaceRequestModel: Codable {
    var model_ids: [Int]
}

struct SuccessResponseModel: Decodable {
    var success: Bool
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


class RacingApiClient: BaseApiClient {
    func searchRacers(make: String, model: String, year: String) async -> [RacerModel]? {
        let result = await self._make_get_request(
            path: "/race/search", queryItems: [
                URLQueryItem(name: "make", value: make),
                URLQueryItem(name: "model", value: model),
                URLQueryItem(name: "year", value: year)
            ] , responseModel: [RacerModel].self
        )
        return result
    }
    func getRacer(make: String, model: String, year: String) async -> RacerModel? {
        let result = await self._make_get_request(
            path: "/racer", queryItems: [
                URLQueryItem(name: "make", value: make),
                URLQueryItem(name: "model", value: model),
                URLQueryItem(name: "year", value: year)
            ] , responseModel: RacerModel.self
        )
        return result
    }
    
    func getRaceInsights(pathName: String) async -> RaceListingModel? {
        return await self._make_get_request(
            path: "/insight\(pathName)", queryItems: [] , responseModel: RaceListingModel.self
        )
    }
    
    func saveRace(modelIds: [Int]) async -> RaceModel? {
        return await self._make_post_request(
            path: "/race/save",
            body: SaveRaceRequestModel(model_ids: modelIds),
            responseModel: RaceModel.self
        )
    }
}


class UserApiClient: BaseApiClient {
    /*
     EXAMPLE:
     func signupUser() {
         let request = SignupRequestModel(username: "test", email: "test@test.com", password: "test123")
         Task {
             let result = await self._make_post_request(
                 path: "/signup", body: request, responseModel: SignupResponseModel.self
             )
             print("Response data:\n \(String(describing: result))")
         }
     }
     */
}
