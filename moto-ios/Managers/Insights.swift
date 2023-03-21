//
//  Insights.swift
//  moto-ios
//
//  Created by Caspar Wylie on 21/03/2023.
//

import Foundation
import UIKit

class RaceListingWindowComponent: WindowComponent {
    
    var races: [RaceModel]!
    
    
    func render(parentView: UIView) {
        for race in self.races {
            self.addRace(race: race)
        }
        parentView.addSubview(self.view)
    }
    
    func addRace(race: RaceModel) {
        // TODO !
        print(race)
    }
    
}

class RecentRacesWindowComponent: RaceListingWindowComponent {
    override func setWindowMeta() {
        self.title = "Recent Races"
    }
 
}


class Head2HeadWindowComponent: RaceListingWindowComponent {
    override func setWindowMeta() {
        self.title = "Most Popular Raced Pairs"
    }
}


class InsightController {
    var windowComponent: RaceListingWindowComponent!
    var apiPath: String!
    var apiClient: RacingApiClient!
    init (apiClient: RacingApiClient, apiPath: String, windowComponent: RaceListingWindowComponent) {
        self.apiClient = apiClient
        self.apiPath = apiPath
        self.windowComponent = windowComponent
        self.populate()
    }
    
    func populate() {
        self.windowComponent.races = []
        Task {
            let results = await apiClient.getRaceInsights(pathName: self.apiPath)
            self.windowComponent.races = results?.races
        }
        
    }
}




class Insights {
    var h2hController: InsightController!
    var recentRacesController: InsightController!
    var h2hWindowComponent: Head2HeadWindowComponent!
    var recentRacesWindowComponent: RecentRacesWindowComponent!
    var apiClient: RacingApiClient!
    
    init (parentView: UIView, apiClient: RacingApiClient) {
        self.apiClient = apiClient
        self.makeComponents()
        self.makeControllers()
        
    }
    func makeComponents() {
        self.h2hWindowComponent = Head2HeadWindowComponent()
        self.recentRacesWindowComponent = RecentRacesWindowComponent()
    }
    
    func makeControllers() {
        self.h2hController = InsightController(
            apiClient: self.apiClient,
            apiPath: "/popular-pairs",
            windowComponent: self.h2hWindowComponent
        )
        
        self.recentRacesController = InsightController(
            apiClient: self.apiClient,
            apiPath: "/recent-races",
            windowComponent: self.recentRacesWindowComponent
        )
    }
}
