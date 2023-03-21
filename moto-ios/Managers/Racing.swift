//
//  Racing.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//
import UIKit
import Foundation
import SwiftSVG


let _DARK_BLUE = UIColor(red: 0.00, green: 0.18, blue: 0.35, alpha: 1.00)
let _GREEN = UIColor(red: 0.22, green: 0.68, blue: 0.53, alpha: 1.00)
let _YELLOW = UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.00)

struct PartialRacer {
    var make: String
    var model: String
    var year: String
}


class RacerInputsComponent {
    var view: UIView!
    var optionsView: UIView!
    var resetButton: UIButton!
    var raceButton: UIButton!
    var addButton: UIButton!
    var skipButton: UIButton!
    
    let inputWidth = global_width / 5
    let inputHeight = 30
    let inputWidthSpacing = 2
    let inputHeightSpacing = 2
    let optionsWidth = 50
    let optionsWidthSpacing = 2
    let optionsHeightSpacing = 2
    let optionsHeight = 25
    
    var width: Int!
    var allInputs: [[UITextField]] = []
    var racerRecommendingController: RacerRecommendingController?
    var raceController: RaceController?

    init () {
        self.width = (3 * self.inputWidth) + (2 * self.inputWidthSpacing)
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 110,
                width: self.width,
                height: 0
            )
        )
        self.makeOptions()
    }
    
    func getRowY() -> Int {
        return self.allInputs.count * (self.inputHeight + self.inputHeightSpacing)
    }
    
    func makeOptions() {
        self.optionsView = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 0,
                width: self.width,
                height: self.optionsHeight * 2 + optionsHeightSpacing
            )
        )
        self.makeAddButton()
        self.makeResetButton()
        self.makeRaceButton()
        self.makeSkipButton()

    }
    
    func makeAddButton() {
        self.addButton = _make_button(text: "+ Add", background: .black, color: .white)
        self.addButton.frame = CGRect(x: 0, y:  0, width: self.optionsWidth, height: self.optionsHeight)
        self.addButton.addTarget(
            self, action: #selector(self.onAddPress), for: .touchDown
        )
    }
    
    func makeResetButton() {
        self.resetButton = _make_button(text: "Reset", background: .black, color: .white)
        self.resetButton.frame = CGRect(
            x: self.optionsWidth + self.optionsWidthSpacing,
            y:  0,
            width: self.optionsWidth,
            height: self.optionsHeight
        )
        self.resetButton.addTarget(
            self, action: #selector(self.onResetPress), for: .touchDown
        )
    }
    
    func makeRaceButton() {
        self.raceButton = _make_button(text: "Race!", background: _GREEN, color: .white)
        self.raceButton.frame = CGRect(
            x: 0,
            y: self.optionsHeight + optionsHeightSpacing,
            width: self.inputWidth * 2 + inputWidthSpacing,
            height: self.optionsHeight
        )
        self.raceButton.addTarget(self, action: #selector(self.onRacePress), for: .touchDown)
    }
    
    func makeSkipButton() {
        self.skipButton = _make_button(text: "Skip to results", background: _YELLOW, color: .white)
        self.skipButton.frame = CGRect(
            x: self.inputWidth * 2 + (inputWidthSpacing * 2),
            y: self.optionsHeight + optionsHeightSpacing,
            width: self.inputWidth,
            height: self.optionsHeight
        )
        self.skipButton.addTarget(self, action: #selector(self.onSkipPress), for: .touchDown)
    }
    
    @objc func onAddPress() {
        self.addInput()
    }
    
    func addInput() {
        let makeIn = _make_text_input(text: "Make...")
        let modelIn = _make_text_input(text: "Model...")
        let yearIn = _make_text_input(text: "Year...")
        modelIn.addTarget(
            self, action: #selector(self.onModelChange), for: .editingChanged
        )
        let y = self.getRowY()
        modelIn.group = allInputs.count
        self.allInputs.append([makeIn, modelIn, yearIn])

        for (index, input) in self.allInputs.last!.enumerated() {
            input.frame = CGRect(
                x: (inputWidth + self.inputWidthSpacing) * index,
                y: y,
                width: self.inputWidth,
                height: self.inputHeight
            )
        }
        
        self.updateFrames()
        self.view.addSubview(makeIn)
        self.view.addSubview(modelIn)
        self.view.addSubview(yearIn)
        
    }
    
    func updateFrames() {
        self.view.frame.size.height = CGFloat(self.getRowY())
        self.optionsView.frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height
    }
    
    @MainActor @objc func onModelChange(input: TextField) {
        let racer = self.getRacerFromInputRow(inputRow: self.allInputs[input.group])
        self.racerRecommendingController?.recommend(
            racer: racer,
            inputRow: input.group
        )
    }
    
    func getRacerFromInputRow(inputRow: [UITextField]) -> PartialRacer {
        return PartialRacer(
            make: inputRow[0].text!,
            model: inputRow[1].text!,
            year: inputRow[2].text!
        )
    }
    
    @MainActor @objc func onRacePress() {
        var racers: [PartialRacer] = []
        for inputs in self.allInputs {
            racers.append(self.getRacerFromInputRow(inputRow: inputs))
        }
        self.raceController?.startRaceFromInputs(racers: racers)
    }
    
    @objc func onSkipPress() {
        print("Skip!!")
    }
    
    func render(parentView: UIView) {
        self.reset()
        self.optionsView.addSubview(self.resetButton)
        self.optionsView.addSubview(self.addButton)
        self.optionsView.addSubview(self.raceButton)
        self.optionsView.addSubview(self.skipButton)
        parentView.addSubview(self.optionsView)
        parentView.addSubview(self.view)
    }
    
    @objc func onResetPress() {
        self.reset()
    }
    
    func reset() {
        self.allInputs = []
        for row in self.view.subviews {
            row.removeFromSuperview()
        }
        self.addInput()
        self.addInput()
    }
    
    func setInputRow(inputRow: Int, racer: PartialRacer) {
        self.allInputs[inputRow][0].text = racer.make
        self.allInputs[inputRow][1].text = racer.model
        self.allInputs[inputRow][2].text = racer.year
    }
}


class RacerRecommenderComponent {
    var view: UIScrollView!
    let width = global_width / 3
    var racerRecommendingController: RacerRecommendingController?
    var rows: [String: PartialRacer] = [:]
    let rowHeight = 25
    let recommenderHieght = 150
    
    init() {
        self.view = UIScrollView(
            frame: CGRect(
                x: _get_center_x(width: self.width) + (global_width / 5),
                y: 110,
                width: self.width,
                height: 0
            )
        )
        self.view.layer.cornerRadius = 5
        self.view.backgroundColor = _DARK_BLUE
    }
    
    func clear() {
        for row in self.view.subviews {
            row.removeFromSuperview()
        }
        self.rows = [:]
        self.view.frame.size.height = 0
    }
    
    func addRacer(racer: PartialRacer) {
        let text = "\(racer.model) \(racer.year)"
        let button = _make_button(text: text, color: .white)
        button.frame = CGRect(
            x: 0,
            y: Int(self.rows.count * self.rowHeight),
            width: self.width,
            height: self.rowHeight
        )
        button.addBottomBorderWithColor(color: .black, width: 1)
        self.view.addSubview(button)
        button.addTarget(
            self, action: #selector(self.onRowSelect), for: .touchUpInside
        )
        self.rows[text] = racer
        self.view.frame.size.height = CGFloat(self.recommenderHieght)
        self.view.contentSize = CGSize(
            width: CGFloat(self.width), height: CGFloat(self.rows.count * self.rowHeight)
        )
    }
    
    @objc func onRowSelect(button: UIButton) {
        let name = button.titleLabel?.text!
        self.racerRecommendingController?.setRacer(racer: self.rows[name!]!)
        
    }

    
    func render(parentView: UIView) {
        parentView.addSubview(self.view)
    }
}



class RacerRecommendingController {
    var apiClient: RacingApiClient!
    var racerRecommenderComponent: RacerRecommenderComponent!
    var racerInputsComponent: RacerInputsComponent!
    var currentInputRow = 0
    init(
        apiClient: RacingApiClient,
        racerInputsComponent: RacerInputsComponent,
        racerRecommenderComponent: RacerRecommenderComponent
    ) {
        self.apiClient = apiClient
        racerInputsComponent.racerRecommendingController = self
        racerRecommenderComponent.racerRecommendingController = self
        self.racerRecommenderComponent = racerRecommenderComponent
        self.racerInputsComponent = racerInputsComponent
    }
    
    @MainActor func recommend(racer: PartialRacer, inputRow: Int) {
        self.currentInputRow = inputRow
        Task {
            self.racerRecommenderComponent.clear()
            let results = await apiClient.searchRacers(make: racer.make, model: racer.model, year: racer.year)
            if let results = results {
                for result in results {
                    self.racerRecommenderComponent.addRacer(
                        racer: PartialRacer(make: result.make_name, model: result.name, year: result.year)
                    )
                }
            }
        }
    }
    
    func setRacer(racer: PartialRacer) {
        self.racerRecommenderComponent.clear()
        self.racerInputsComponent.setInputRow(inputRow: self.currentInputRow, racer: racer)
    }
}


class ControlPanelComponent {
    var view: UIView!
    let width = global_width
    var racerInputsComponent: RacerInputsComponent!
    var racerRecommenderComponent: RacerRecommenderComponent!
    init() {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 0,
                width: self.width,
                height: global_height
            )
        )
        self.racerInputsComponent = RacerInputsComponent()
        self.racerRecommenderComponent = RacerRecommenderComponent()
    }
    
    func render(parentView: UIView) {
        self.racerInputsComponent.render(parentView: self.view)
        self.racerRecommenderComponent.render(parentView: self.view)
        parentView.addSubview(self.view)
    }
}

class RacerComponent {
    var view: UIImageView!
    var racer: RacerModel!
    var label: UILabel!
    
    static let labelHeight = 20
    let labelWidth = 200
    static let racerSpacing = 15
    static let racerSize = Double(global_height) / 12
    
    var timer: Timer? = nil

    init (racer: RacerModel) {
        self.racer = racer
        self.makeRacerImage()
        self.makeRacerLabel()
    }
    
    func makeRacerImage() {
        let file = "images/\(racer.style)_type_white"
        self.view = UIImageView()
        self.view.image = UIImage(named: file)
        self.view.frame = CGRect(
            x: 10,
            y: 0,
            width: Int(Self.racerSize * 1.8),
            height: Int(Self.racerSize)
        )
    }
    
    func makeRacerLabel() {
        self.label = _make_text(
            text: "\(self.racer.make_name) \(self.racer.name)",
            align: .left,
            size: 15,
            color: .white
        )
        self.label.frame = CGRect(
            x: 0,
            y: Int(RacerComponent.racerSize) + 10,
            width: labelWidth,
            height: RacerComponent.labelHeight
        )
    }
    
    static func getFullHeight() -> Int {
        return (
            Int(Self.racerSize)
            + Self.racerSpacing
            + Self.labelHeight
        )
    }
    
    func move(onFinish: @escaping (RacerModel) -> Void) {
        var progress = Double(self.racer.torque)! / 25
        let acc = Double(self.racer.torque)! / Double(self.racer.weight)!
        let ptw = Double(self.racer.power)! / Double(self.racer.weight)!

    
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.040, repeats: true, block: { _ in
            let momentum = (acc * progress) + 1 + (ptw * 7)
            progress += 0.001
            self.view.frame.origin.x += momentum
            if Double(self.view.frame.origin.x) >= Double(global_width) * 0.8 {
                self.stopMove()
                onFinish(self.racer)
            }
        })
    }
    
    func stopMove() {
        self.timer!.invalidate()
    }
    
    func render(parentView: UIView) {
        self.view.addSubview(self.label)
        parentView.addSubview(self.view)
    }
}

class RaceViewComponent {
    var view: UIView!
    
    var racerComponents: [RacerComponent] = []

    init() {
        self.view = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: global_width,
                height: global_height
            )
        )
        self.view.backgroundColor = .black
    }
    
    func render(parentView: UIView) {
        self.view.removeFromSuperview()
        let height = RacerComponent.getFullHeight()
        for (index, racerComponent) in self.racerComponents.enumerated() {
            racerComponent.view.frame.origin.y = CGFloat(index * height)
            racerComponent.render(parentView: self.view)
        }
        parentView.addSubview(self.view)
    }
    
    func reset() {
        for racer in self.racerComponents {
            racer.view.removeFromSuperview()
        }
        self.racerComponents = []
    }
    
    func addRacer(racer: RacerModel) {
        self.racerComponents.append(RacerComponent(racer: racer))
    }
}


class RacerResultComponent {
    var racer: RacerModel!
    var view: UIView!
    var finishPosition = 0
    static let width = global_width / 3
    static let height = 130
    
    var positionLabel: UILabel!
    var racerLabel: UILabel!
    var statsLabel: UILabel!

    
    init (racer: RacerModel, finishPosition: Int) {
        self.racer = racer
        self.finishPosition = finishPosition
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: Self.width),
                y: 0,
                width: Self.width,
                height: Self.height
            )
        )
        self.makeHeader()
        self.makeStats()
    }
    
    func makeHeader() {
        var positionText = ""
        switch(self.finishPosition) {
            case 1:
                positionText = "1st"
            case 2:
                positionText = "2nd"
            case 3:
                positionText = "3rd"
            default:
                positionText = String(self.finishPosition) + "th"
        }
        self.positionLabel = _make_text(text: positionText, size: 25, color: _YELLOW)
        self.racerLabel = _make_text(text: self.racer.full_name, color: _YELLOW)

    }
    
    func makeStats() {
        let statsText = "Power: \(self.racer.power) hp \nTorque: \(self.racer.torque) Nm \nWeight: \(self.racer.weight) kg"
        self.statsLabel = _make_text(text: statsText, color: .white)
        self.statsLabel.numberOfLines = 3
    }
    
    func render(parentView: UIView) {
        self.view.addSubview(self.positionLabel)
        self.positionLabel.frame = CGRect(x: 0, y: 0, width: Self.width, height: 30)

        self.view.addSubview(self.racerLabel)
        self.racerLabel.frame = CGRect(x: 0, y: 30, width: Self.width, height: 20)

        self.view.addSubview(self.statsLabel)
        self.statsLabel.frame = CGRect(x: 0, y: 50, width: Self.width, height: 60)


        parentView.addSubview(self.view)
    }
}


class RaceResultsComponent: WindowComponent {
    
    var racerResultComponents: [RacerResultComponent] = []

    override func setWindowMeta() {
        self.backgroundColor = .black
        self.title = "Results"
        self.titleColor = .white
    }
    
    func reset() {
        for racerResult in self.racerResultComponents {
            racerResult.view.removeFromSuperview()
        }
        self.racerResultComponents = []
        
    }
    
    func addFinishedRacer(racer: RacerModel) {
        self.racerResultComponents.append(
            RacerResultComponent(
                racer: racer,
                finishPosition: self.racerResultComponents.count + 1
            )
        )
    }
    
    func render(parentView: UIView) {
        self.view.removeFromSuperview()
        var lastY: CGFloat = 40
        for racerResultComponent in self.racerResultComponents {
            racerResultComponent.view.frame.origin.y = lastY
            racerResultComponent.render(parentView: self.view)
            lastY += CGFloat(RacerResultComponent.height)
        }
        self.view.contentSize = CGSize(
            width: CGFloat(RacerResultComponent.width),
            height: lastY + CGFloat(RacerResultComponent.height)
        )
        parentView.addSubview(self.view)
    }
}


class RaceController {
    var mainView: UIView!
    var raceViewComponent: RaceViewComponent!
    var racerInputsComponent: RacerInputsComponent!
    var raceResultsComponent: RaceResultsComponent!
    var apiClient: RacingApiClient!
    var loadedRacers: [RacerModel] = []
    
    init(
        apiClient: RacingApiClient,
        mainView: UIView,
        raceViewComponent: RaceViewComponent,
        racerInputsComponent: RacerInputsComponent,
        raceResultsComponent: RaceResultsComponent
    ) {
        self.apiClient = apiClient
        self.mainView = mainView
        self.racerInputsComponent = racerInputsComponent
        self.raceViewComponent = raceViewComponent
        self.raceResultsComponent = raceResultsComponent
        self.racerInputsComponent.raceController = self
    }
    
    func reset() {
        self.loadedRacers = []
        self.raceViewComponent.reset()
        self.raceResultsComponent.reset()
    }
    
    @MainActor func startRaceFromInputs(racers: [PartialRacer]) {
        self.reset()
        Task {
            for partialRacer in racers {
                // ADJUST WEIGHT
                // SAVE RACE!
                let racer = await self.apiClient.getRacer(
                    make: partialRacer.make,
                    model: partialRacer.model,
                    year: partialRacer.year
                )
                if let racer = racer {
                    self.loadedRacers.append(racer)
                }
            }
            self.startRace()
        }
    }
    
    func startRace() {
        for racer in self.loadedRacers {
            self.raceViewComponent.addRacer(racer: racer)
        }
        self.raceViewComponent.render(parentView: self.mainView)
        for racerComponent in self.raceViewComponent.racerComponents {
            racerComponent.move() { (racer) -> () in
                self.raceResultsComponent.addFinishedRacer(racer: racer)
                if self.raceResultsComponent.racerResultComponents.count == self.loadedRacers.count {
                    self.finishRace()
                }
            }
        }
    }
    
    func finishRace() {
        self.raceResultsComponent.render(parentView: self.mainView)
        self.raceViewComponent.view.removeFromSuperview()
    }
}


class Racing {
    var apiClient: RacingApiClient!
    var parentView: UIView!
    
    var controlPanelComponent: ControlPanelComponent!
    var raceViewComponent: RaceViewComponent!
    var raceResultsComponent: RaceResultsComponent!
    
    var racerRecommendingController: RacerRecommendingController!
    var raceController: RaceController!

    
    init(apiClient: RacingApiClient, parentView: UIView) {
        self.apiClient = apiClient
        self.parentView = parentView
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents () {
        self.controlPanelComponent = ControlPanelComponent()
        self.raceViewComponent = RaceViewComponent()
        self.raceResultsComponent = RaceResultsComponent()
    }
    
    func makeControllers () {
        self.racerRecommendingController = RacerRecommendingController(
            apiClient: self.apiClient,
            racerInputsComponent: self.controlPanelComponent.racerInputsComponent,
            racerRecommenderComponent: self.controlPanelComponent.racerRecommenderComponent
        )
        self.raceController = RaceController(
            apiClient: self.apiClient,
            mainView: self.parentView,
            raceViewComponent: self.raceViewComponent,
            racerInputsComponent: self.controlPanelComponent.racerInputsComponent,
            raceResultsComponent: self.raceResultsComponent
        )
    }

    func render() {
        self.controlPanelComponent.render(parentView: self.parentView)
    }
}
