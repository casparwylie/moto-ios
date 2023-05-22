//
//  Racing.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//
import UIKit
import Foundation


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


protocol RacerInputOwnerComponent: AnyObject {
    var racerRecommendingController: RacerRecommendingController? { get set }
}


class RacerInputComponent: RacerInputOwnerComponent {
    
    var view: UIView!
    var makeIn: UITextField!
    var modelIn: UITextField!
    var yearIn: UITextField!
    
    var makeLogoImageView: UIImageView?
    var modelIconImageView: UIImageView?
    
    static let inputHeight = uiDef().ROW_HEIGHT
    static let inputWidthSpacing = 2
    static let inputHeightSpacing = 4
    let logoSpacing = 5
    let logoImageSize = uiDef().ROW_HEIGHT
    let modelIconImageSize = uiDef().ROW_HEIGHT - 10


    var racerRecommendingController: RacerRecommendingController?
    
    static func getWidth() -> Int {
        return Int(Double(globalWidth) * 0.8)
    }
      
    @MainActor @objc func onModelChange(input: TextField) {
        self.racerRecommendingController?.recommendModel(inputComponent: self)
        self.yearIn.text = ""
    }
    
    @MainActor @objc func onMakeChange(input: TextField) {
        self.modelIconImageView?.removeFromSuperview()
        self.racerRecommendingController?.recommendMake(inputComponent: self)
        self.modelIn.text = ""
        self.yearIn.text = ""
    }
    
    func getInputWidth() -> CGFloat {
        return CGFloat((Int(Self.getWidth() + 1 ) / 3) - Self.inputWidthSpacing)
    }
    
    func reset() {
        self.makeIn.text = ""
        self.modelIn.text = ""
        self.yearIn.text = ""
    }

    func makeInputs() {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: Int(Self.getWidth()), height: Self.inputHeight))
        let inputFrame = CGRect(x: 0, y: 0, width: Int(self.getInputWidth()), height: Self.inputHeight)
        
        self.makeIn = TextField().make(text: "Make...")
        self.makeIn.frame = inputFrame
        self.makeIn.addTarget(
            self, action: #selector(self.onMakeChange), for: .editingChanged
        )
        self.makeIn.addTarget(
            self, action: #selector(self.onMakeChange), for: .editingDidBegin
        )
        self.modelIn = TextField().make(text: "Model...")
        self.modelIn.frame = inputFrame
        self.yearIn = TextField().make(text: "Year...")
        self.yearIn.frame = inputFrame
        self.modelIn.addTarget(
            self, action: #selector(self.onModelChange), for: .editingChanged
        )
        self.modelIn.addTarget(
            self, action: #selector(self.onModelChange), for: .editingDidBegin
        )
        _ = expandAcross(
            views: [self.makeIn, self.modelIn, self.yearIn], spacing: CGFloat(Self.inputWidthSpacing)
        )
    }

    
    func getPartialRacerFromInputs() -> PartialRacer? {
        let racer = PartialRacer(
            make: (self.makeIn.text?.trimmingCharacters(in: .whitespacesAndNewlines)) ?? "",
            model: (self.modelIn.text?.trimmingCharacters(in: .whitespacesAndNewlines)) ?? "",
            year: (self.yearIn.text?.trimmingCharacters(in: .whitespacesAndNewlines)) ?? ""
        )
        if racer.make.count > 0 {
            return racer
        } else {
            return nil
        }
    }
    
    
    func setRacer(racer: RacerModel) {
        self.makeIn.text = racer.make_name
        self.modelIn.text = racer.name
        self.yearIn.text = racer.year
        
        self.setModelIcon(style: racer.style)
    }
    
    func setMake(make: String) {
        self.makeIn.text = make
        self.setMakeLogo(make: make)
    }
    
    func setMakeLogo(make: String) {
        self.makeLogoImageView?.removeFromSuperview()
        if let url = getMakeLogoURL(make: make) {
            self.makeLogoImageView = UIImageView()
            self.makeLogoImageView!.load(url: url) {
                self.makeLogoImageView!.frame = CGRect(
                    x: Int(self.getInputWidth() - CGFloat(self.logoImageSize + self.logoSpacing)),
                    y: 0,
                    width: self.logoImageSize,
                    height: self.logoImageSize
                )
                self.view.addSubview(self.makeLogoImageView!)
            }
        }
    }
    
    func setModelIcon(style: String) {
        self.modelIconImageView?.removeFromSuperview()
        self.modelIconImageView = UIImageView()
        self.modelIconImageView?.backgroundColor = .black
        let file = "images/\(style)_type_white"
        self.modelIconImageView!.image = UIImage(named: file)
        let width = Int(Double(self.modelIconImageSize) * RacerComponent.racerScaleWidth)
        self.modelIconImageView!.frame = CGRect(
            x: Int(self.getInputWidth() * 2 - CGFloat(width + self.logoSpacing)),
            y: 5,
            width: width,
            height: self.modelIconImageSize
        )
        self.view.addSubview(self.modelIconImageView!)
    }
    
    func render(parentView: UIView) {
        self.makeInputs()
        self.view.addSubview(makeIn)
        self.view.addSubview(modelIn)
        self.view.addSubview(yearIn)
        
        parentView.addSubview(self.view)
    }
}


class RacerInputsComponent: RacerInputOwnerComponent {
    var view: UIView!
    var optionsView: UIView!
    var resetButton: UIButton!
    var raceButton: UIButton!
    var addButton: UIButton!
    var skipButton: UIButton!
    

    let optionsWidthSpacing = 2
    let optionsHeightSpacing = 2
    let optionsHeight = uiDef().ROW_HEIGHT
    let halfSpacing = RacerInputComponent.inputWidthSpacing / 2
    static let viewY = HeaderComponent.height + MenuComponent.height + uiDef().ROW_HEIGHT
    
    var currentInputY = 0
    
    var allInputs: [RacerInputComponent] = []
    
    
    var raceController: RaceController?
    var racerRecommendingController: RacerRecommendingController?
    
    func getOptionsWidth() -> Int {
        return ((RacerInputComponent.getWidth() / 3) / 2) - 1
    }
    
    func getThirdWidth() -> Int {
        return RacerInputComponent.getWidth() / 3
    }

    func makeOptions() {
        self.optionsView = UIView(
            frame: CGRect(
                x: getCenterX(width: RacerInputComponent.getWidth()),
                y: 0,
                width:  RacerInputComponent.getWidth(),
                height: self.optionsHeight * 2 + optionsHeightSpacing
            )
        )
        self.makeAddButton()
        self.makeResetButton()
        self.makeRaceButton()
        self.makeSkipButton()

    }

    
    func makeAddButton() {
        self.addButton = Button().make(text: "+ Add", background: .black, color: .white)
        self.addButton.frame = CGRect(x: 0, y:  0, width: self.getOptionsWidth(), height: self.optionsHeight)
        self.addButton.addTarget(
            self, action: #selector(self.onAddPress), for: .touchDown
        )
    }
    
    func makeResetButton() {
        self.resetButton = Button().make(text: "Reset", background: .black, color: .white)
        self.resetButton.frame = CGRect(
            x: self.getOptionsWidth() + self.optionsWidthSpacing,
            y:  0,
            width: self.getOptionsWidth(),
            height: self.optionsHeight
        )
        self.resetButton.addTarget(
            self, action: #selector(self.onResetPress), for: .touchDown
        )
    }
    
    func makeRaceButton() {
        self.raceButton = Button().make(text: "Race!", background: _GREEN, color: .white)
        self.raceButton.frame = CGRect(
            x: 0,
            y: self.optionsHeight + self.optionsHeightSpacing,
            width: (2 * self.getThirdWidth()) - self.halfSpacing,
            height: self.optionsHeight
        )
        self.raceButton.addTarget(self, action: #selector(self.onRacePress), for: .touchDown)
    }
    
    func makeSkipButton() {
        self.skipButton = Button().make(text: "Skip to results", background: _YELLOW, color: .white)
        self.skipButton.frame = CGRect(
            x: (2 * self.getThirdWidth()) + self.halfSpacing,
            y: self.optionsHeight + self.optionsHeightSpacing,
            width: self.getThirdWidth() - self.halfSpacing,
            height: self.optionsHeight
        )
        self.skipButton.addTarget(self, action: #selector(self.onSkipPress), for: .touchDown)
    }
    
    @objc func onAddPress() {
        if self.allInputs.count < uiDef().MAX_RACERS_PER_RACE {
            _ = self.addInput()
        }
    }
    
    func addInput() -> RacerInputComponent {
        let input = RacerInputComponent()
        input.racerRecommendingController = self.racerRecommendingController
        input.render(parentView: self.view)
        self.allInputs.insert(input, at: 0)
        self.currentInputY = Int(
            expandDown(
                views: self.allInputs.map{$0.view}, spacing: CGFloat(RacerInputComponent.inputHeightSpacing)
            )
        )
        self.updateFrames()
        return input
    }
    
    func updateFrames() {
        self.view.frame.size.height = CGFloat(self.currentInputY)
        self.optionsView.frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height
    }

    
    func getPartialRacersFromAllInputs() -> [PartialRacer] {
        return self.allInputs.compactMap { $0.getPartialRacerFromInputs() }
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

    func setAllRacers(racers: [RacerModel]) {
        self.reset(addInputs: false)
        for racer in racers {
            let input = self.addInput()
            input.setRacer(racer: racer)
            input.setMake(make: racer.make_name)
        }
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: getCenterX(width: RacerInputComponent.getWidth()),
                y:  Self.viewY,
                width: RacerInputComponent.getWidth(),
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


class RacerRecommenderComponent: OptionListingComponent {
    var racerRecommendingController: RacerRecommendingController?
}


class RacerRecommendingController {
    var apiClient: RacingApiClient!
    var currentInputComponent: RacerInputComponent?
    var currentRacerRecommenderComponent: RacerRecommenderComponent?
    
    init(
        apiClient: RacingApiClient,
        recommenderComponent: RacerRecommenderComponent,
        raceInputOwner: RacerInputOwnerComponent
    ) {
        self.apiClient = apiClient
        self.currentRacerRecommenderComponent = recommenderComponent
        self.currentRacerRecommenderComponent?.racerRecommendingController = self
        raceInputOwner.racerRecommendingController = self
    }
    
    @MainActor func recommendMake(inputComponent: RacerInputComponent) {
        self.currentInputComponent = inputComponent
        self.placeRecommender()
        Task {
            self.currentRacerRecommenderComponent?.clear()
            if let partialMake = self.currentInputComponent?.makeIn.text! {
                if let result = await apiClient.searchRacerMakes(make: partialMake) {
                    if result.makes.count == 1 && result.makes.first!.lowercased() == partialMake.lowercased() {
                        self.setMake(make: result.makes.first!)
                        return
                    }
                    
                    for make in result.makes {
                        self.currentRacerRecommenderComponent?.addRow(text: make) {
                            self.setMake(make: make)
                        }
                    }
                }
            }
        }
    }
 
    @MainActor func recommendModel(inputComponent: RacerInputComponent) {
        self.currentInputComponent = inputComponent
        self.placeRecommender()
        Task {
            self.currentRacerRecommenderComponent?.clear()
            if let partialRacer = self.currentInputComponent?.getPartialRacerFromInputs() {
                let results = await apiClient.searchRacers(
                    make: partialRacer.make, model: partialRacer.model, year: partialRacer.year
                )
                if let results = results {
                    if results.count == 1 && results.first!.name.lowercased() == partialRacer.model.lowercased() {
                        self.setRacer(racer: results.first!)
                        return
                    }
                    for result in results {
                        let text = "\(result.name) \(result.year)"
                        self.currentRacerRecommenderComponent?.addRow(text: text) {
                            self.setRacer(racer: result)
                        }
                    }
                }
            }
        }
    }

    func placeRecommender() {
        if let inputComponent = self.currentInputComponent {
            if let point = inputComponent.view.superview?.convert(
                inputComponent.view.frame.origin, to: nil
            ) {
                self.currentRacerRecommenderComponent?.setFrame(
                    frame: CGRect(
                        x: point.x,
                        y: point.y + self.currentInputComponent!.view.frame.size.height,
                        width: self.currentInputComponent!.view.frame.size.width,
                        height: 0
                    )
                )
            }
        }
    }
    func setMake(make: String) {
        self.currentRacerRecommenderComponent?.clear()
        self.currentInputComponent?.setMake(make: make)
    }
    func setRacer(racer: RacerModel) {
        self.currentRacerRecommenderComponent?.clear()
        self.currentInputComponent?.setRacer(racer: racer)
    }
}


class ControlPanelComponent {
    var view: UIView!
    var racerInputsComponent: RacerInputsComponent!
    var racerRecommenderComponent: RacerRecommenderComponent!
    
    func getWidth() -> Int {
        return globalWidth
    }
    
    func getHeight() -> Int {
        return globalHeight
    }
    
    init() {
        self.racerInputsComponent = RacerInputsComponent()
        self.racerRecommenderComponent = RacerRecommenderComponent()
    }
        
    func makeRacerRecommender() {
        self.racerRecommenderComponent.render(parentView: self.view)
    }
    
    func render(parentView: UIView) {
        self.view = UIView(frame: CGRect(
            x: getCenterX(width: self.getWidth()),
            y: 0,
            width: self.getWidth(),
            height: self.getHeight()
        ))
        self.view.backgroundColor = .white
        self.racerInputsComponent.render(parentView: self.view)
        self.makeRacerRecommender()
        parentView.addSubview(self.view)
    }
}

class TrafficLightComponent {
    var view: UIView!
    let lightSpacing = 3
    
    var light1: UIView!
    var light2: UIView!
    var light3: UIView!
    
    func getSize() -> Int {
        return globalWidth / 7
    }
    
    
    func makeLight() -> UIView {
        let light = UIView()
        light.frame = CGRect(x: 0, y: 0, width: self.getSize(), height: self.getSize())
        light.backgroundColor = .red
        light.layer.cornerRadius = CGFloat(self.getSize() / 2)
        light.layer.masksToBounds = true
        return light
    }
    
    func makeLights () {
        self.light1 = self.makeLight()
        self.light2 = self.makeLight()
        self.light3 = self.makeLight()
        _ = expandDown(
            views: [self.light1, self.light2, self.light3], spacing: CGFloat(self.lightSpacing)
        )
    }
 
    func reset() {
        self.light1.backgroundColor = .none
        self.light2.backgroundColor = .none
        self.light3.backgroundColor = .none
    }
    
    func run() {
        self.reset()
        show(view: self.view)
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
            hide(view: self.view)
        }
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: getCenterX(width: self.getSize()),
                y: getCenterY(height: self.getSize() * 3),
                width: self.getSize(),
                height: self.getSize() * 3
            )
        )
        self.makeLights()
        self.view.addSubview(self.light1)
        self.view.addSubview(self.light2)
        self.view.addSubview(self.light3)
        parentView.addSubview(self.view)
        hide(view: self.view)
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
    
    // race constants
    let startTorqueDivider = 25.0
    let progressConstant = 0.3
    let initialSpecDivider = 5.0
    static let screenFinishPercent = 0.8
    static let racerScaleWidth = 1.8
    
    var timer: Timer? = nil
    
    var resolvedWeight: Double!
    
    static func getRacerSize() -> Double {
        Double(globalHeight) / 14
    }

    init (racer: RacerModel) {
        self.racer = racer
        
        self.resolvedWeight = self.racer.resolvedWeight()
        
        self.acc = Double(self.racer.torque)! / self.resolvedWeight / self.initialSpecDivider
        self.ptw = Double(self.racer.power)! / self.resolvedWeight / self.initialSpecDivider
    }
    
    func makeRacerImage() {
        let file = "images/\(racer.style)_type_white"
        self.view = UIImageView()
        self.view.image = UIImage(named: file)
        self.view.frame = CGRect(
            x: 10,
            y: 0,
            width: Int(Self.getRacerSize() * Self.racerScaleWidth),
            height: Int(Self.getRacerSize())
        )
    }
    
    func makeRacerLabel() {
        self.label = Label().make(
            text: "\(self.racer.make_name) \(self.racer.name)",
            align: .left,
            size: 15,
            color: .white
        )
        self.label.frame = CGRect(
            x: 0,
            y: Int(Self.getRacerSize()),
            width: labelWidth,
            height: RacerComponent.labelHeight
        )
    }
    
    static func getFullHeight() -> Int {
        return (
            Int(Self.getRacerSize())
            + Self.racerSpacing
            + Self.labelHeight
        )
    }
    
    func move(speed: Double, onFinish: @escaping (RacerModel, Double) -> Void) {
        var progress = Double(self.racer.torque)! / self.startTorqueDivider
        var milliseconds: Double = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: speed / 1000, repeats: true, block: { _ in
            let momentum = (self.ptw * progress) + (self.acc * progress) + 1
            progress += self.progressConstant
            self.view.frame.origin.x += CGFloat(Int(momentum))
            if Double(self.view.frame.origin.x) >= Double(globalWidth) * Self.screenFinishPercent {
                self.stopMove()
                onFinish(self.racer, (milliseconds / 1000) * 3)
            }
            milliseconds += 40
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
    var finishLineView: UIImageView!
    
    var racerComponents: [RacerComponent] = []
    
    static let startY = 10.0
    
    func reset() {
        self.racerComponents.forEach{ (racer) in racer.view.removeFromSuperview() }
        self.racerComponents = []
    }
    
    func addRacer(racer: RacerModel) {
        self.racerComponents.append(RacerComponent(racer: racer))
    }
    
    func renderFinishLine() {
        self.finishLineView = UIImageView()
        self.finishLineView.image = UIImage(named: "images/finish_line.png")
        self.finishLineView.frame = CGRect(
            x: Int(Double(globalWidth) * RacerComponent.screenFinishPercent - 0.02),
            y: 0,
            width: 10,
            height: globalHeight
        )
        self.view.addSubview(self.finishLineView)
    }
    
    func render(parentView: UIView) {
        self.view?.removeFromSuperview()
        self.view = UIScrollView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: globalWidth,
                height: globalHeight
            )
        )
        self.view.backgroundColor = .black
        var trackLineViews: [UIView] = []
        self.renderFinishLine()
        self.racerComponents.forEach {
            (racerComponent) in
            racerComponent.render(parentView: self.view)
            let trackLineView = UIView()
            trackLineView.frame = CGRect(x: 0, y: 0, width: globalWidth, height: 1)
            trackLineView.backgroundColor = UIColor(red: 0.27, green: 0.27, blue: 0.27, alpha: 1.00)
            trackLineViews.append(trackLineView)
            self.view.addSubview(trackLineView)
        }
        let totalTrackSpacing = (
            Double(RacerComponent.labelHeight)
            + RacerComponent.getRacerSize()
            + Double(RacerComponent.racerSpacing)
        )
        _ = expandDown(
            views: trackLineViews,
            startY: totalTrackSpacing,
            spacing: totalTrackSpacing
        )
        let lastY = expandDown(
            views: self.racerComponents.map{ $0.view },
            startY: Self.startY,
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
    var time = 0.0
    static let height = uiDef().FONT_SIZE * 6 + 40
    
    var positionLabel: UILabel!
    var racerLabel: UILabel!
    var statsLabel: UILabel!
    var makeLogoView: UIImageView!

    
    init (racer: RacerModel, finishPosition: Int, time: Double) {
        self.racer = racer
        self.finishPosition = finishPosition
        self.time = time
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
        
        let roundedTime = Double(round(10000 * self.time) / 10000)
        //let zeroSixtyTime = Double(round(((roundedTime / 3) - 0.5) * 10000) / 10000)
        positionText += " - \(roundedTime)s" // 0-60 \(zeroSixtyTime)"
        self.positionLabel = Label().make(text: positionText, size: CGFloat(uiDef().HEADER_FONT_SIZE), color: _YELLOW)
        self.racerLabel = Label().make(text: self.racer.full_name, color: _YELLOW)
    }
    
    func makeStats() {
        let statsText = (
            "Power: \(self.racer.power) hp \nTorque: \(self.racer.torque) Nm \nWeight: \(self.racer.resolvedWeight()) kg"
        )
        self.statsLabel = Label().make(text: statsText, color: .white)
        self.statsLabel.lineBreakMode = .byWordWrapping
        self.statsLabel.numberOfLines = 3
    }
    
    func makeMakeLogoView() {
        self.makeLogoView = UIImageView()
        if let url = getMakeLogoURL(make: self.racer.make_name) {
            self.makeLogoView!.load(url: url) {}
        }
    }
    
    func render(parentView: UIView) {
        self.view = UIView(
            frame: CGRect(
                x: getCenterX(width: globalWidth),
                y: 0,
                width: globalWidth,
                height: Self.height
            )
        )
        self.makeMakeLogoView()
        self.makeHeader()
        self.makeStats()
        

        self.view.addSubview(self.positionLabel)
        self.positionLabel.frame = CGRect(x: 0, y: 0, width: globalWidth, height: uiDef().HEADER_FONT_SIZE)
        
        self.view.addSubview(self.makeLogoView)
        self.makeLogoView.frame = CGRect(x: getCenterX(width: 40), y: 0, width: 40, height: 40)

        self.view.addSubview(self.racerLabel)
        self.racerLabel.frame = CGRect(x: 0, y: 0, width: globalWidth, height: uiDef().FONT_SIZE)

        self.view.addSubview(self.statsLabel)
        self.statsLabel.frame = CGRect(x: 0, y: 0, width: globalWidth, height: uiDef().FONT_SIZE * 4)
        
        _ = expandDown(views: [self.makeLogoView, self.positionLabel, self.racerLabel, self.statsLabel])

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
    
    let optionsViewHeight = uiDef().ROW_HEIGHT * 2
    let optionFontSize = uiDef().FONT_SIZE
    let resultsSpacing = 50

    
    var raceId: Int?
    
    func getOptionWidth() -> Int {
        return globalWidth / 6
    }
    

    override func setWindowMeta() {
        self.backgroundColor = .black
        self.title = "Results"
        self.titleColor = .white
        self.headerImageName = "images/header_street_type_white"
    }
    
    func makeOptionsView() {
        self.optionsView = UIView()
        self.optionsView.frame = CGRect(
            x: 0,
            y: Self.headerOffset + 10,
            width: 0,
            height: self.optionsViewHeight
        )
    }
    
    func makeResultOptions() {
        let halfOptionsHeight = self.optionsViewHeight / 2
        let optionWidth = self.getOptionWidth()
        self.voteOptionsView = UIView()
        self.voteOptionsView.frame = CGRect(
            x: 0, y: 0, width: optionWidth, height: self.optionsViewHeight
        )
        
        self.voteUpButton = Button().make(
            text: "Upvote", background: _GREEN, color: .white, size: self.optionFontSize
        )
        self.voteUpButton.frame = CGRect(
            x: 0, y: 0, width: optionWidth, height: halfOptionsHeight
        )
        self.voteUpButton.addTarget(
            self, action: #selector(self.onVoteUpPress), for: .touchDown
        )
        
        self.voteDownButton = Button().make(
            text: "Downvote", background: _RED, color: .white, size: self.optionFontSize
        )
        self.voteDownButton.frame = CGRect(
            x: 0, y: halfOptionsHeight, width: optionWidth, height: halfOptionsHeight
        )
        self.voteDownButton.addTarget(
            self, action: #selector(self.onVoteDownPress), for: .touchDown
        )
        
        self.viewCommentsButton = Button().make(
            text: "View Comments", background: _YELLOW, color: .white, size: self.optionFontSize
        )
        self.viewCommentsButton.frame = CGRect(
            x: 0, y: 0, width: optionWidth, height: self.optionsViewHeight
        )
        self.viewCommentsButton.addTarget(
            self, action: #selector(self.onViewCommentsPress), for: .touchDown
        )
        
        self.shareButton = Button().make(
            text: "✄ Share Race URL", background: _YELLOW, color: .white, size: self.optionFontSize
        )
        self.shareButton.frame = CGRect(
            x: 0, y: 0, width: optionWidth, height: self.optionsViewHeight
        )
        self.shareButton.addTarget(
            self, action: #selector(self.onShareButtonPress), for: .touchDown
        )
        
        self.fbButton = Button().make(
            text: "f Share", background: _BLUE, color: .white, size: self.optionFontSize
        )
        self.fbButton.frame = CGRect(
            x: 0, y: 0, width: optionWidth, height: self.optionsViewHeight
        )
        self.fbButton.addTarget(self, action: #selector(self.onShareFbPress), for: .touchDown)
        
        let width = expandAcross(
            views: [self.voteOptionsView, self.viewCommentsButton, self.shareButton, self.fbButton],
            spacing: 2
        )
        self.optionsView.frame.size.width = width
        self.optionsView.frame.origin.x = CGFloat(getCenterX(width: Int(width)))
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
            if let fbShareUrl = URL(
                string: "https://www.facebook.com/sharer/sharer.php?u=\(BASE_DOMAIN)/r/\(id)"
            ) {
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
    
    func addFinishedRacer(racer: RacerModel, time: Double) {
        self.racerResultComponents.append(
            RacerResultComponent(
                racer: racer,
                finishPosition: self.racerResultComponents.count + 1,
                time: time
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
        let lastY = expandDown(
            views: self.racerResultComponents.map{$0.view},
            startY:  CGFloat(Self.headerOffset + self.optionsViewHeight + self.resultsSpacing),
            spacing: CGFloat(self.resultsSpacing)
        )
        self.view.contentSize = CGSize(
            width: CGFloat(globalWidth),
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
    var racerRecommendingController: RacerRecommendingController?
    
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
        self.racerInputsComponent.view.endEditing(true)
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
        self.racerInputsComponent.setAllRacers(racers: self.loadedRacers)
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
                racerComponent.move(speed: speed) { (racer, time) -> () in
                    self.raceResultsWindowComponent.addFinishedRacer(racer: racer, time: time)
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
    
    func setKeyboardView() {
        self.racerInputsComponent.view.frame.origin = CGPoint(
            x: getCenterX(width: RacerInputComponent.getWidth()), y: 10
        )
        self.racerInputsComponent.updateFrames()
        self.racerRecommendingController?.placeRecommender()
    }
    
    func unsetKeyboardView() {
        self.racerInputsComponent.view.frame.origin = CGPoint(
            x: getCenterX(width: RacerInputComponent.getWidth()), y: RacerInputsComponent.viewY
        )
        self.racerInputsComponent.updateFrames()
        self.racerRecommendingController?.placeRecommender()
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
            recommenderComponent: self.controlPanelComponent.racerRecommenderComponent,
            raceInputOwner: self.controlPanelComponent.racerInputsComponent
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
    
    func injectControllers(
        commentsController: CommentsController, informerController: InformerController
    ) {
        self.raceController.commentsController = commentsController
        self.raceController.informerController = informerController
        self.raceController.racerRecommendingController = self.racerRecommendingController
        self.raceResultsWindowComponent.informer = informerController
    }

    func render() {
        self.controlPanelComponent.render(parentView: self.parentView)
        self.trafficLightComponent.render(parentView: self.parentView)
    }
}
