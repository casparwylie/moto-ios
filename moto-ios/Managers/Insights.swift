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
    
    func render(parentView: UIView) {
        super.render()
        self.insightController?.populate()
        parentView.addSubview(self.view)
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
    var raceController: RaceController!
    init (
        apiClient: RacingApiClient,
        apiPath: String,
        windowComponent: RaceListingWindowComponent,
        raceController: RaceController) {
        self.apiClient = apiClient
        self.apiPath = apiPath
        self.windowComponent = windowComponent
        self.raceController = raceController
    }
    
    func populate() {
        Task {
            if let results = await apiClient.getRaceInsights(pathName: self.apiPath) {
                await self.windowComponent.populate(races: results.races)
            }
        }
    }
    
    func startRace(race: RaceModel) {
        raceController?.setRacersFromRace(race: race)
        raceController?.startRace()
    }
}


class InsightsManager {
    var h2hController: InsightController!
    var recentRacesController: InsightController!
    var h2hWindowComponent: Head2HeadWindowComponent!
    var recentRacesWindowComponent: RecentRacesWindowComponent!
    var apiClient: RacingApiClient!
    var raceController: RaceController!
    
    init (parentView: UIView, apiClient: RacingApiClient, raceController: RaceController) {
        self.apiClient = apiClient
        self.raceController = raceController
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
            windowComponent: self.h2hWindowComponent,
            raceController: self.raceController
        )
        self.h2hWindowComponent.insightController = h2hController
        
        self.recentRacesController = InsightController(
            apiClient: self.apiClient,
            apiPath: "/recent-races",
            windowComponent: self.recentRacesWindowComponent,
            raceController: self.raceController
        )
        self.recentRacesWindowComponent.insightController = recentRacesController
    }
    
    func startRace() {
        
    }
}
