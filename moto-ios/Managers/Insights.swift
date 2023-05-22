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
    var insightController: InsightController?
    
    var noCommentsLabel: UILabel!
    
    @MainActor func populate(races: [RaceModel]) {
        self.noCommentsLabel.removeFromSuperview()
        if races.count > 0 {
            self.raceButtons.forEach{ raceButton in raceButton.removeFromSuperview() }
            let buttons = races.map {self.addRaceButton(race: $0)}
            let lastY = expandDown(views: buttons, startY: CGFloat(Self.headerOffset))
            self.view.contentSize = CGSize(width: self.view.frame.width, height: lastY)
        } else {
            self.view.addSubview(self.noCommentsLabel)
        }
    }
    
    
    func makeNoCommentsLabel() {
        self.noCommentsLabel = Label().make(text: "There are no races yet.", align: .center)
        self.noCommentsLabel.frame = CGRect(
            x: getCenterX(width: globalWidth),
            y: Self.headerOffset,
            width: globalWidth,
            height: uiDef().ROW_HEIGHT
        )
    }

    func addRaceButton(race: RaceModel) -> UILabel {
        let buttonLabel = race.racers.map { $0.full_name }.joined(separator: "   VS   ")
        let label = Label().make(text: buttonLabel, align: .center)

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = CGRect(
            x: getCenterX(width: globalWidth),
            y: 0,
            width: globalWidth,
            height: 0
        )
        label.sizeToFit()
        label.frame.size.width = CGFloat(globalWidth)
    
        label.addBottomBorderWithColor(color: _DARK2_TBLUE, width: 1)
        
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
        super.render(parentView: parentView)
        self.insightController?.populate()
        self.makeNoCommentsLabel()
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
        self.windowComponent.startLoading()
        Task {
            if let results = await apiClient.getRaceInsights(
                name: self.apiName, flags: self.apiFlags
            ) {
                await self.windowComponent.populate(races: results.races)
            }
            await self.windowComponent.stopLoading()

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
