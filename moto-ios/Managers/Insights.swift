//
//  Insights.swift
//  moto-ios
//
//  Created by Caspar Wylie on 21/03/2023.
//

import Foundation
import UIKit

class RaceLabelTapGesture: UITapGestureRecognizer {
    var race: RaceModel?
}

class RaceListingWindowComponent: WindowComponent {
    
    var raceButtons: [UIButton] = []
    let buttonWidth = Double(global_width) * 0.8
    var insightController: InsightController?
    
    
    @MainActor func populate(races: [RaceModel]) {
        self.raceButtons.forEach{ raceButton in raceButton.removeFromSuperview() }
        let buttons = races.map {self.addRaceButton(race: $0)}
        let lastY = _expand_as_list(views: buttons, startY: self.titleLabel.frame.height)
        self.view.contentSize = CGSize(width: self.view.frame.width, height: lastY)
    }

    func addRaceButton(race: RaceModel) -> UILabel {
        let buttonLabel = race.racers.map { $0.full_name }.joined(separator: "   VS   ")
        let label = _make_text(text: buttonLabel, align: .center)

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = CGRect(
            x: _get_center_x(width: Int(self.buttonWidth)),
            y: 0,
            width: Int(self.buttonWidth),
            height: 0
        )
        label.sizeToFit()
        label.frame.size.width = CGFloat(self.buttonWidth)
    
        label.addBottomBorderWithColor(color: .gray, width: 1)
        
        let labelTapGesture = RaceLabelTapGesture(target: self, action: #selector(onRacePress))
        labelTapGesture.race = race
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(labelTapGesture)
        self.view.addSubview(label)
        return label
    }
    
    @objc func onRacePress(_ gesture: RaceLabelTapGesture) {
        self.view.removeFromSuperview()
        self.insightController?.startRace(race: gesture.race!)
    }
    
    
    override func render(parentView: UIView) {
        self.insightController?.populate()
        super.render(parentView: parentView)
    }
    
}


class RecentRacesWindowComponent: RaceListingWindowComponent {
    override func setWindowMeta() {
        self.title = "Recent Races"
    }
}


class MyRecentRacesWindowComponent: RaceListingWindowComponent {
    override func setWindowMeta() {
        self.title = "Me > My Recent Races"
    }
}


class Head2HeadWindowComponent: RaceListingWindowComponent {
    
    override func setWindowMeta() {
        self.title = "Most Popular Raced Pairs"
    }
}


class InsightController {
    var windowComponent: RaceListingWindowComponent!
    var apiName: String!
    var apiFlags: [String: String]!
    var apiClient: RacingApiClient!
    var raceController: RaceController?
    init (
        windowComponent: RaceListingWindowComponent,
        apiClient: RacingApiClient,
        apiName: String,
        apiFlags: [String: String] = [:]
    ) {
        self.apiClient = apiClient
        self.apiName = apiName
        self.apiFlags = apiFlags
        self.windowComponent = windowComponent
        self.windowComponent.insightController = self
    }
    
    func populate() {
        Task {
            if let results = await apiClient.getRaceInsights(
                name: self.apiName, flags: self.apiFlags
            ) {
                await self.windowComponent.populate(races: results.races)
            }
        }
    }
    
    func startRace(race: RaceModel) {
        self.raceController?.setRacersFromRace(race: race)
        self.raceController?.startRace()
    }
}


class InsightsManager {
    var h2hController: InsightController!
    var recentRacesController: InsightController!
    var myRecentRacesController: InsightController!
    
    var h2hWindowComponent: Head2HeadWindowComponent!
    var recentRacesWindowComponent: RecentRacesWindowComponent!
    var myRecentRacesWindowComponent: MyRecentRacesWindowComponent!
    
    var apiClient: RacingApiClient!
    
    init (parentView: UIView, apiClient: RacingApiClient) {
        self.apiClient = apiClient
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents() {
        self.h2hWindowComponent = Head2HeadWindowComponent()
        self.recentRacesWindowComponent = RecentRacesWindowComponent()
        self.myRecentRacesWindowComponent = MyRecentRacesWindowComponent()
    }
    
    func makeControllers() {
        self.h2hController = InsightController(
            windowComponent: self.h2hWindowComponent,
            apiClient: self.apiClient,
            apiName: "popular-pairs"
        )
        self.recentRacesController = InsightController(
            windowComponent: self.recentRacesWindowComponent,
            apiClient: self.apiClient,
            apiName: "recent-races"
        )
        self.myRecentRacesController = InsightController(
            windowComponent: self.myRecentRacesWindowComponent,
            apiClient: self.apiClient,
            apiName: "recent-races"
        )
    }
    
    func injectControllers(raceController: RaceController) {
        self.h2hController.raceController = raceController
        self.recentRacesController.raceController = raceController
        self.myRecentRacesController.raceController = raceController
    }
}
