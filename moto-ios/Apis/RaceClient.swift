//
//  RaceClient.swift
//  moto-ios
//
//  Created by Caspar Wylie on 30/03/2023.
//

import Foundation


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


struct RaceVoteRequestModel: Codable {
    var vote: Int
    var race_unique_id: String
}


struct RaceVotesResponseModel: Decodable {
    var upvotes: Int
    var downvotes: Int
}

struct HasVotedResponseModel: Decodable {
    var voted: Bool
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
    
    func getRace(raceId: String?) async -> RaceModel? {
        let result = await self._make_get_request(
            path: "/race", queryItems: [
                URLQueryItem(name: "race_id", value: raceId)
            ] , responseModel: RaceModel.self
        )
        return result
    }
    
    func getRaceInsights(name: String, flags: [String: String]) async -> RaceListingModel? {
        let queryItems = flags.map {(key, value) in URLQueryItem(name: key, value: value)}
        return await self._make_get_request(
            path: "/insight/\(name)", queryItems: queryItems, responseModel: RaceListingModel.self
        )
    }
    
    func saveRace(modelIds: [Int]) async -> RaceModel? {
        return await self._make_post_request(
            path: "/race/save",
            body: SaveRaceRequestModel(model_ids: modelIds),
            responseModel: RaceModel.self
        )
    }
    
    func voteRace(vote: Int, raceUniqueId: String) async -> SuccessResponseModel? {
        return await self._make_post_request(
            path: "/race/vote",
            body: RaceVoteRequestModel(vote: vote, race_unique_id: raceUniqueId),
            responseModel: SuccessResponseModel.self
        )
    }
    
    func getRaceVotes(raceUniqueId: String) async -> RaceVotesResponseModel? {
        return await self._make_get_request(
            path: "/race/votes",
            queryItems:  [URLQueryItem(name: "race_unique_id", value: raceUniqueId)],
            responseModel: RaceVotesResponseModel.self
        )
    }
    
    func getUserHasVoted(raceUniqueId: String) async -> HasVotedResponseModel? {
        return await self._make_get_request(
            path: "/race/vote/voted",
            queryItems:  [URLQueryItem(name: "race_unique_id", value: raceUniqueId)],
            responseModel: HasVotedResponseModel.self
        )
    }
}

