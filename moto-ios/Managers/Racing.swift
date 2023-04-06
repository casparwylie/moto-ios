//
//  Racing.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//
import UIKit
import Foundation


let _MAX_RACERS_PER_RACE = 8


struct PartialRacer {
    var make: String
    var model: String
    var year: String
}

extension PartialRacer: Equatable {
    static func == (lhs: PartialRacer, rhs: PartialRacer) -> Bool {
        return
            lhs.make == rhs.make &&
            lhs.model == rhs.model &&
            lhs.year == rhs.year
    }
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
        if self.allInputs.count < _MAX_RACERS_PER_RACE {
            _ = self.addInput()
        }
    }
    
    func addInput() -> Int {
        let makeIn = _make_text_input(text: "Make...")
        let modelIn = _make_text_input(text: "Model...")
        let yearIn = _make_text_input(text: "Year...")
        let rowId = allInputs.count
        modelIn.addTarget(
            self, action: #selector(self.onModelChange), for: .editingChanged
        )
        modelIn.addTarget(
            self, action: #selector(self.onModelChange), for: .editingDidBegin
        )
        let y = self.getRowY()
        modelIn.group = rowId
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
        return rowId
    }
    
    func updateFrames() {
        self.view.frame.size.height = CGFloat(self.getRowY())
        self.optionsView.frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height
    }
    
    @MainActor @objc func onModelChange(input: TextField) {
        if let racer = self.getPartialRacerFromInputRow(inputRow: self.allInputs[input.group]) {
            self.racerRecommendingController?.recommend(
                racer: racer,
                inputRow: input.group
            )
        }
    }
    
    func getPartialRacerFromInputRow(inputRow: [UITextField]) -> PartialRacer? {
        let racer = PartialRacer(
            make: inputRow[0].text!,
            model: inputRow[1].text!,
            year: inputRow[2].text!
        )
        if racer.make.count > 0 && racer.model.count > 0  {
            return racer
        } else {
            return nil
        }
    }
    
    func getPartialRacersFromAllInputs() -> [PartialRacer] {
        var racers: [PartialRacer] = []
        for row in self.allInputs {
            if let racer = self.getPartialRacerFromInputRow(inputRow: row) {
                racers.append(racer)
            }
        }
        return racers
    }
    
    @MainActor @objc func onRacePress() {
        let racers = self.getPartialRacersFromAllInputs()
        Task {
            await self.raceController?.setRacersFromInputs(racers: racers)
            self.raceController?.startRace()
        }
    }
    
    @MainActor @objc func onSkipPress() {
        let racers = self.getPartialRacersFromAllInputs()
        Task {
            await self.raceController?.setRacersFromInputs(racers: racers)
            self.raceController?.startRace(skip: true)
        }
    }
  
    
    @objc func onResetPress() {
        self.reset()
    }
    
    func reset(addInputs: Bool = true) {
        self.allInputs = []
        self.view.subviews.forEach { row in row.removeFromSuperview() }
        if addInputs {
            _ = self.addInput()
            _ = self.addInput()
        }
    }
    
    func setInputRow(inputRow: Int, racer: PartialRacer) {
        self.allInputs[inputRow][0].text = racer.make
        self.allInputs[inputRow][1].text = racer.model
        self.allInputs[inputRow][2].text = racer.year
    }
    
    func setInputRows(racers: [RacerModel]) {
        self.reset(addInputs: false)
        for racer in racers {
            let inputRow = self.addInput()
            let partialRacer = PartialRacer(
                make: racer.make_name, model: racer.name, year: racer.year
            )
            self.setInputRow(
                inputRow: inputRow,
                racer: partialRacer
            )
            
        }
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 110,
                width: self.width,
                height: 0
            )
        )
        self.makeOptions()
        self.reset()
        self.optionsView.addSubview(self.resetButton)
        self.optionsView.addSubview(self.addButton)
        self.optionsView.addSubview(self.raceButton)
        self.optionsView.addSubview(self.skipButton)
        parentView.addSubview(self.optionsView)
        parentView.addSubview(self.view)
    }
}


class RacerRecommenderComponent {
    var view: UIScrollView!
    let width = global_width / 3
    var racerRecommendingController: RacerRecommendingController?
    var rows: [String: PartialRacer] = [:]
    let rowHeight = 25
    let recommenderHeight = 150
    

    func clear() {
        self.view.subviews.forEach {row in  row.removeFromSuperview()}
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
        self.view.frame.size.height = CGFloat(self.recommenderHeight)
        self.view.contentSize = CGSize(
            width: CGFloat(self.width),
            height: CGFloat(self.rows.count * self.rowHeight)
        )
    }
    
    @objc func onRowSelect(button: UIButton) {
        let name = button.titleLabel?.text!
        self.racerRecommendingController?.setRacer(racer: self.rows[name!]!)
        
    }

    func render(parentView: UIView) {
        self.view = UIScrollView(
            frame: CGRect(
                x: _get_center_x(width: self.width) + (global_width / 5),
                y: 110,
                width: self.width,
                height: 0
            )
        )
        self.view.layer.cornerRadius = _DEFAULT_CORNER_RADIUS
        self.view.backgroundColor = _DARK_BLUE
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
            let results = await apiClient.searchRacers(
                make: racer.make, model: racer.model, year: racer.year
            )
            if let results = results {
                for result in results {
                    self.racerRecommenderComponent.addRacer(
                        racer: PartialRacer(
                            make: result.make_name, model: result.name, year: result.year
                        )
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
        self.racerInputsComponent = RacerInputsComponent()
        self.racerRecommenderComponent = RacerRecommenderComponent()
    }
    
    func render(parentView: UIView) {
        self.view = UIView(frame: CGRect(
            x: _get_center_x(width: self.width),
            y: 0,
            width: self.width,
            height: global_height
        ))
        self.view.backgroundColor = .white
        self.racerInputsComponent.render(parentView: self.view)
        self.racerRecommenderComponent.render(parentView: self.view)
        parentView.addSubview(self.view)
    }
}

class TrafficLightComponent {
    var view: UIView!
    let size = global_width / 7
    let lightSpacing = 3
    
    var light1: UIView!
    var light2: UIView!
    var light3: UIView!
    
    
    func makeLight() -> UIView {
        let light = UIView()
        light.frame = CGRect(x: 0, y: 0, width: self.size, height: self.size)
        light.backgroundColor = .red
        light.layer.cornerRadius = CGFloat(self.size / 2)
        light.layer.masksToBounds = true
        light.backgroundColor = .black
        return light
    }
    
    func makeLights () {
        self.light1 = self.makeLight()
        self.light2 = self.makeLight()
        self.light3 = self.makeLight()
        _ = _expand_as_list(
            views: [self.light1, self.light2, self.light3], spacing: CGFloat(self.lightSpacing)
        )
    }
 
    func reset() {
        self.light1.backgroundColor = .black
        self.light2.backgroundColor = .black
        self.light3.backgroundColor = .black
    }
    
    func run() {
        self.reset()
        _show(view: self.view)
        self.view.superview?.bringSubviewToFront(self.view)
        self.light1.backgroundColor = _RED
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            self.light2.backgroundColor = _YELLOW
        }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            self.light1.backgroundColor = _GREEN
            self.light2.backgroundColor = _GREEN
            self.light3.backgroundColor = _GREEN
        }
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            _hide(view: self.view)
        }
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.size),
                y: _get_center_y(height: self.size * 3),
                width: self.size,
                height: self.size * 3
            )
        )
        self.makeLights()
        self.view.addSubview(self.light1)
        self.view.addSubview(self.light2)
        self.view.addSubview(self.light3)
        self.view.backgroundColor = .black
        parentView.addSubview(self.view)
        _hide(view: self.view)
    }
    
}

class RacerComponent {
    var view: UIImageView!
    var racer: RacerModel!
    var label: UILabel!
    var acc: Double!
    var ptw: Double!
    
    static let labelHeight = 20
    let labelWidth = 200
    static let racerSpacing = 15
    static let racerSize = Double(global_height) / 12
    
    var timer: Timer? = nil
    
    var resolvedWeight: Double!

    init (racer: RacerModel) {
        self.racer = racer
        self.resolveWeight()
        
        self.acc = Double(self.racer.torque)! / self.resolvedWeight
        self.ptw = Double(self.racer.power)! / self.resolvedWeight
    }
    
    func resolveWeight() {
        if self.racer.weight_type == "dry" {
            self.resolvedWeight = Double(self.racer.weight)! + 20
        } else {
            self.resolvedWeight = Double(self.racer.weight)!
        }
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
            y: Int(RacerComponent.racerSize),
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
    
    func move(speed: Double, onFinish: @escaping (RacerModel) -> Void) {
        var progress = Double(self.racer.torque)! / 25
        self.timer = Timer.scheduledTimer(withTimeInterval: speed / 1000, repeats: true, block: { _ in
            let momentum = (self.acc * progress) + 1 + (self.ptw * 7)
            progress += 0.01
            self.view.frame.origin.x += CGFloat(Int(momentum))
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
        self.makeRacerImage()
        self.makeRacerLabel()
        self.view.addSubview(self.label)
        parentView.addSubview(self.view)
    }
}

class RaceViewComponent {
    var view: UIScrollView!
    
    var racerComponents: [RacerComponent] = []

    init() {
        self.view = UIScrollView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: global_width,
                height: global_height
            )
        )
        self.view.backgroundColor = .black
    }
    
    func reset() {
        self.racerComponents.forEach{ (racer) in racer.view.removeFromSuperview() }
        self.racerComponents = []
    }
    
    func addRacer(racer: RacerModel) {
        self.racerComponents.append(RacerComponent(racer: racer))
    }
    
    func render(parentView: UIView) {
        self.view.removeFromSuperview()
        self.racerComponents.forEach {
            (racerComponent) in racerComponent.render(parentView: self.view)
        }
        let lastY = _expand_as_list(
            views: self.racerComponents.map{ $0.view },
            spacing: CGFloat(RacerComponent.labelHeight + RacerComponent.racerSpacing)
        )
        self.view.contentSize = CGSize(width: self.view.frame.width, height: lastY)
        parentView.addSubview(self.view)
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
        self.view.addSubview(self.positionLabel)
        self.positionLabel.frame = CGRect(x: 0, y: 0, width: Self.width, height: 30)

        self.view.addSubview(self.racerLabel)
        self.racerLabel.frame = CGRect(x: 0, y: 30, width: Self.width, height: 20)

        self.view.addSubview(self.statsLabel)
        self.statsLabel.frame = CGRect(x: 0, y: 50, width: Self.width, height: 60)

        parentView.addSubview(self.view)
    }
}


class RaceResultsWindowComponent: WindowComponent {
    
    var racerResultComponents: [RacerResultComponent] = []
    var informer: InformerController?
    
    var raceController: RaceController?
    
    var shareButton: UIButton!
    var fbButton: UIButton!
    var viewCommentsButton: UIButton!
    var voteDownButton: UIButton!
    var voteUpButton: UIButton!
    
    var voteOptionsView: UIView!
    var optionsView: UIView!
    
    let optionsViewHeight = 40
    let optionWidth = global_width / 6
    let optionFontSize = 15

    
    var raceId: Int?
    

    override func setWindowMeta() {
        self.backgroundColor = .black
        self.title = "Results"
        self.titleColor = .white
    }
    
    func makeOptionsView() {
        self.optionsView = UIView()
        self.optionsView.frame = CGRect(
            x: 0,
            y: self.titleHeight + 10,
            width: 0, height: self.optionsViewHeight
        )
    }
    
    func makeResultOptions() {
        let halfOptionsHeight = self.optionsViewHeight / 2
        
        self.voteOptionsView = UIView()
        self.voteOptionsView.frame = CGRect(
            x: 0, y: 0, width: self.optionWidth, height: self.optionsViewHeight
        )
        
        self.voteUpButton = _make_button(
            text: "Upvote", background: _GREEN, color: .white, size: self.optionFontSize
        )
        self.voteUpButton.frame = CGRect(
            x: 0, y: 0, width: self.optionWidth, height: halfOptionsHeight
        )
        self.voteUpButton.addTarget(
            self, action: #selector(self.onVoteUpPress), for: .touchDown
        )
        
        self.voteDownButton = _make_button(
            text: "Downvote", background: _RED, color: .white, size: self.optionFontSize
        )
        self.voteDownButton.frame = CGRect(
            x: 0, y: halfOptionsHeight, width: self.optionWidth, height: halfOptionsHeight
        )
        self.voteDownButton.addTarget(
            self, action: #selector(self.onVoteDownPress), for: .touchDown
        )
        
        self.viewCommentsButton = _make_button(
            text: "View Comments", background: _YELLOW, color: .white, size: self.optionFontSize
        )
        self.viewCommentsButton.frame = CGRect(
            x: 0, y: 0, width: self.optionWidth, height: self.optionsViewHeight
        )
        self.viewCommentsButton.addTarget(
            self, action: #selector(self.onViewCommentsPress), for: .touchDown
        )
        
        self.shareButton = _make_button(
            text: "✄ Share Race URL", background: _YELLOW, color: .white, size: self.optionFontSize
        )
        self.shareButton.frame = CGRect(
            x: 0, y: 0, width: self.optionWidth, height: self.optionsViewHeight
        )
        self.shareButton.addTarget(
            self, action: #selector(self.onShareButtonPress), for: .touchDown
        )
        
        self.fbButton = _make_button(
            text: "f Share", background: _BLUE, color: .white, size: self.optionFontSize
        )
        self.fbButton.frame = CGRect(
            x: 0, y: 0, width: self.optionWidth, height: self.optionsViewHeight
        )
        self.fbButton.addTarget(self, action: #selector(self.onShareFbPress), for: .touchDown)
        
        let width = _expand_across(
            views: [self.voteOptionsView, self.viewCommentsButton, self.shareButton, self.fbButton],
            spacing: 2
        )
        self.optionsView.frame.size.width = width
        self.optionsView.frame.origin.x = CGFloat(_get_center_x(width: Int(width)))
    }
    
    
    @objc func onViewCommentsPress(button: UIButton) {
        self.raceController?.viewComments()
    }
    
    @MainActor @objc func onVoteDownPress() {
        self.raceController?.voteRace(vote: 0)
    }
    
    @MainActor @objc func onVoteUpPress() {
        self.raceController?.voteRace(vote: 1)
    }
    
    @MainActor @objc func onShareButtonPress() {
        if let id = self.raceId {
            UIPasteboard.general.string = "\(BASE_DOMAIN)/r/\(id)"
            self.informer?.inform(message: "Copied sharable URL!")
        }
    }
    
    @MainActor @objc func onShareFbPress() {
        if let id = self.raceId {
            if let fbShareUrl = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(BASE_DOMAIN)/r/\(id)") {
                UIApplication.shared.open(fbShareUrl)
            }
        }
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
    
    @MainActor func setVoteLabels(upvotes: Int, downvotes: Int, voted: Bool) {
        self.voteUpButton.setTitle("Upvote (\(upvotes))", for: .normal)
        self.voteDownButton.setTitle("Downvote (\(downvotes))", for: .normal)
    }
    
    override func render(parentView: UIView) {
        self.makeOptionsView()
        self.makeResultOptions()
        self.voteOptionsView.addSubview(self.voteDownButton)
        self.voteOptionsView.addSubview(self.voteUpButton)
        
        self.optionsView.addSubview(self.voteOptionsView)
        self.optionsView.addSubview(self.viewCommentsButton)
        self.optionsView.addSubview(self.shareButton)
        self.optionsView.addSubview(self.fbButton)
        
        
        super.render(parentView: parentView)
        self.racerResultComponents.forEach { racerResultComponent in
            racerResultComponent.render(parentView: self.view)
        }
        let lastY = _expand_as_list(
            views: self.racerResultComponents.map{$0.view},
            startY: self.titleLabel.frame.height + CGFloat(self.optionsViewHeight) + 20
        )
        self.view.contentSize = CGSize(
            width: CGFloat(RacerResultComponent.width),
            height: lastY
        )
        self.view.addSubview(self.optionsView)
    }
}


class RaceController {
    var mainView: UIView!
    var raceViewComponent: RaceViewComponent!
    var racerInputsComponent: RacerInputsComponent!
    var raceResultsWindowComponent: RaceResultsWindowComponent!
    var trafficLightComponent: TrafficLightComponent!
    var informerController: InformerController?
    var commentsController: CommentsController?
    
    var apiClient: RacingApiClient!
    var loadedRacers: [RacerModel] = []
    var lastPartialRacers: [PartialRacer] = []
    var currentUniqueRaceId: String?
    
    init(
        apiClient: RacingApiClient,
        mainView: UIView,
        raceViewComponent: RaceViewComponent,
        racerInputsComponent: RacerInputsComponent,
        raceResultsWindowComponent: RaceResultsWindowComponent,
        trafficLightComponent: TrafficLightComponent
    ) {
        self.apiClient = apiClient
        self.mainView = mainView
        self.racerInputsComponent = racerInputsComponent
        self.raceViewComponent = raceViewComponent
        self.raceResultsWindowComponent = raceResultsWindowComponent
        self.trafficLightComponent = trafficLightComponent
        self.racerInputsComponent.raceController = self
        self.raceResultsWindowComponent.raceController = self
    }
    
    func reset() {
        self.raceViewComponent.reset()
        self.raceResultsWindowComponent.reset()
    }
    
    @MainActor func setRacersFromInputs(racers: [PartialRacer]) async {
        if racers == lastPartialRacers {
            return
        }
        self.lastPartialRacers = racers
        self.loadedRacers = []
        for partialRacer in racers {
            let racer = await self.apiClient.getRacer(
                make: partialRacer.make,
                model: partialRacer.model,
                year: partialRacer.year
            )
            if let racer = racer {
                self.loadedRacers.append(racer)
            }
        }
        if let race = await self.apiClient.saveRace(modelIds: self.loadedRacers.map{$0.model_id}) {
            self.setRaceInfo(raceId: race.race_id, raceUniqueId: race.race_unique_id)
        }
    }
    
    func setRacersFromRace(race: RaceModel) {
        self.loadedRacers = race.racers
        self.setRaceInfo(raceId: race.race_id, raceUniqueId: race.race_unique_id)
        self.racerInputsComponent.setInputRows(racers: self.loadedRacers)
        self.lastPartialRacers = self.racerInputsComponent.getPartialRacersFromAllInputs()
    }
    
    func setRaceInfo(raceId: Int, raceUniqueId: String) {
        self.currentUniqueRaceId = raceUniqueId
        self.raceResultsWindowComponent.raceId = raceId
    }
    
    func startRace(skip: Bool = false) {
        self.reset()
        if self.loadedRacers.count == 0 {
            return
        }
        for racer in self.loadedRacers {
            self.raceViewComponent.addRacer(racer: racer)
        }
        self.raceViewComponent.render(parentView: self.mainView)
        var startDelay = 3.0
        var speed = 40.0
        if skip {
            startDelay = 0.0
            speed = 1.0
        } else {
            self.trafficLightComponent.run()
        }
        Timer.scheduledTimer(withTimeInterval: startDelay, repeats: false) { (timer) in
            for racerComponent in self.raceViewComponent.racerComponents {
                racerComponent.move(speed: speed) { (racer) -> () in
                    self.raceResultsWindowComponent.addFinishedRacer(racer: racer)
                    if (
                        self.raceResultsWindowComponent.racerResultComponents.count
                        == self.loadedRacers.count)
                    {
                        self.finishRace()
                    }
                }
            }
        }
    }
    
    @MainActor func voteRace(vote: Int) {
        Task {
            if let uniqueId = self.currentUniqueRaceId {
                if let result = await self.apiClient.voteRace(vote: vote, raceUniqueId: uniqueId) {
                    if result.success {
                        self.setVotes()
                        self.informerController?.inform(message: "Successfully voted!")
                    } else {
                        self.informerController?.inform(message: "You have already voted.", mood: "bad")
                    }
                } else {
                    // TODO: Handle 403 error code explicitly
                    self.informerController?.inform(message: "You must have an account to vote.", mood: "bad")
                }
            }
        }
    }
    
    @MainActor func setVotes() {
        Task {
            if let uniqueId = self.currentUniqueRaceId {
                if let votes = await self.apiClient.getRaceVotes(raceUniqueId: uniqueId) {
                    if let userHasVoted = await self.apiClient.getUserHasVoted(raceUniqueId: uniqueId) {
                        self.raceResultsWindowComponent.setVoteLabels(
                            upvotes: votes.upvotes,
                            downvotes: votes.downvotes,
                            voted: userHasVoted.voted
                        )
                    }
                }
            }
        }
    }
    
    @MainActor func finishRace() {
        self.raceResultsWindowComponent.render(parentView: self.mainView)
        self.setVotes()
        self.raceViewComponent.view.removeFromSuperview()
    }
    
    func viewComments() {
        if let uniqueRaceId = self.currentUniqueRaceId {
            self.commentsController?.viewComments(uniqueRaceId: uniqueRaceId)
        }
    }
}


class RacingManager {
    var apiClient: RacingApiClient!
    var parentView: UIView!
    var informerController: InformerController!
    
    var controlPanelComponent: ControlPanelComponent!
    var raceViewComponent: RaceViewComponent!
    var raceResultsWindowComponent: RaceResultsWindowComponent!
    var trafficLightComponent: TrafficLightComponent!
    
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
        self.raceResultsWindowComponent = RaceResultsWindowComponent()
        self.trafficLightComponent = TrafficLightComponent()
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
            raceResultsWindowComponent: self.raceResultsWindowComponent,
            trafficLightComponent: self.trafficLightComponent
        )
    }
    
    func injectControllers(commentsController: CommentsController, informerController: InformerController) {
        self.raceController.commentsController = commentsController
        self.raceController.informerController = informerController
        self.raceResultsWindowComponent.informer = informerController
    }

    func render() {
        self.controlPanelComponent.render(parentView: self.parentView)
        self.trafficLightComponent.render(parentView: self.parentView)
    }
}
