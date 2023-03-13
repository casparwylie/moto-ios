//
//  Racing.swift
//  moto-ios
//
//  Created by Caspar Wylie on 12/03/2023.
//
import UIKit
import Foundation


let _DARK_BLUE = UIColor(red: 0.00, green: 0.18, blue: 0.35, alpha: 1.00)

class HeaderComponent {
    var view: UIView!
    let width = 300
    let height = 100
    var headerLabel: UILabel!
    var creditLabel: UILabel!
    
    init() {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 20,
                width: self.width,
                height: 0
            )
        )
        self.makeHeaderLabel()
        self.makeHeaderCreditLabel()
    }
    
    func makeHeaderLabel() {
        self.headerLabel = _make_text(text: "What Bikes Win?", font: "Tourney", size: 30)
        self.headerLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: 30)
    }
    
    func makeHeaderCreditLabel() {
        self.creditLabel = _make_text(text: "By Caspar Wylie", font: "Tourney")
        self.creditLabel.frame = CGRect(
            x: 0, y: Int(self.headerLabel.frame.height), width: self.width, height: 20
        )
    }
    
    func render(parentView: UIView) {
        self.view.addSubview(self.headerLabel)
        self.view.addSubview(self.creditLabel)
        parentView.addSubview(self.view)
    }
}


class MenuItemComponent {
    var text: String!
    var button: UIButton!
    
    init(text: String) {
        self.text = text
        self.button = _make_button(text: self.text)
        self.button.frame.size = self.button.intrinsicContentSize
        self.button.addBottomBorderWithColor(color: .black, width: 1)
    }
    
    func render(parentView: UIView) {
        parentView.addSubview(self.button)
    }
}

class MenuComponent {
    var view: UIView!
    var menuItems: [MenuItemComponent] = []
    let spacing = 10
    
    init() {
        self.view = UIView()
        self.menuItems = [
            MenuItemComponent(text: "Introduction"),
            MenuItemComponent(text: "Head2Heads"),
            MenuItemComponent(text: "Recent Races"),
            MenuItemComponent(text: "Login"),
            MenuItemComponent(text: "Sign Up"),
        ]
    }

    func render(parentView: UIView) {
        var totalWidth = 0
        for item in self.menuItems {
            item.button.frame = CGRect(
                x: CGFloat(totalWidth),
                y: 0,
                width: item.button.frame.size.width,
                height: item.button.frame.size.height)
            item.render(parentView: self.view)
            totalWidth += Int(item.button.frame.width) + self.spacing
        }
        self.view.frame = CGRect(
            x: _get_center_x(width: totalWidth),
            y: 70,
            width: totalWidth,
            height: 30
        )
        parentView.addSubview(self.view)
    }
}

class RacerInputsComponent {
    var view: UIView!
    var optionsView: UIView!
    var resetButton: UIButton!
    var addButton: UIButton!
    let inputWidth = global_width / 5
    let inputHeight = 30
    let inputWidthSpacing = 2
    let inputHeightSpacing = 2
    let optionsWidth = 50
    let optionsWidthSpacing = 2
    let optionsHeight = 25
    var width: Int!
    var allInputs: [[UITextField]] = []
    var racerRecommendingController: RacerRecommendingController?
    
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
                height: self.optionsHeight
            )
        )
        self.addButton = _make_button(text: "+ Add", background: .black, color: .white)
        self.addButton.frame = CGRect(x: 0, y:  0, width: self.optionsWidth, height: self.optionsHeight)
        self.addButton.addTarget(
            self, action: #selector(self.addInput), for: .touchDown
        )
        self.resetButton = _make_button(text: "Reset", background: .black, color: .white)
        self.resetButton.frame = CGRect(
            x: self.optionsWidth + self.optionsWidthSpacing,
            y:  0,
            width: self.optionsWidth,
            height: self.optionsHeight
        )
        self.resetButton.addTarget(
            self, action: #selector(self.reset), for: .touchDown
        )

    }
    
    @objc func addInput() {
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
        let inputs = self.allInputs[input.group]
        self.racerRecommendingController?.recommend(
            make: inputs[0].text!,
            model: inputs[1].text!,
            year: inputs[2].text!,
            inputRow: input.group
        )
    }
    
    func render(parentView: UIView) {
        self.reset()
        self.optionsView.addSubview(self.resetButton)
        self.optionsView.addSubview(self.addButton)
        parentView.addSubview(self.optionsView)
        parentView.addSubview(self.view)
    }
    
   @objc func reset() {
        self.allInputs = []
        for row in self.view.subviews {
            row.removeFromSuperview()
        }
        self.addInput()
        self.addInput()
    }
    
    func setInputRow(inputRow: Int, racer: (make: String, model: String, year: String)) {
        self.allInputs[inputRow][0].text = racer.make
        self.allInputs[inputRow][1].text = racer.model
        self.allInputs[inputRow][2].text = racer.year
    }
}


class RacerRecommenderComponent {
    var view: UIScrollView!
    let width = global_width / 3
    var racerRecommendingController: RacerRecommendingController?
    var rows: [String: (make: String, model: String, year: String)] = [:]
    let rowHeight = 20
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
    
    func addRow(racer: (make: String, model: String, year: String)) {
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
        self.view.frame.size.height = 150
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
    
    @MainActor func recommend(make: String, model: String, year: String, inputRow: Int) {
        self.currentInputRow = inputRow
        Task {
            self.racerRecommenderComponent.clear()
            let results = await apiClient.searchRacers(make: make, model: model, year: year)
            for result in results {
                self.racerRecommenderComponent.addRow(
                    racer: (make: result.make_name, model: result.name, year: result.year)
                )
            }
        }
    }
    
    func setRacer(racer: (make: String, model: String, year: String)) {
        self.racerRecommenderComponent.clear()
        self.racerInputsComponent.setInputRow(inputRow: self.currentInputRow, racer: racer)
    }
}


class ControlPanelComponent {
    var view: UIView!
    let width = global_width
    var racerInputsComponent: RacerInputsComponent!
    var racerRecommenderComponent: RacerRecommenderComponent!
    var headerComponent: HeaderComponent!
    var menuComponent: MenuComponent!
    init() {
        self.view = UIView(
            frame: CGRect(
                x: _get_center_x(width: self.width),
                y: 0,
                width: self.width,
                height: global_height
            )
        )
        self.headerComponent = HeaderComponent()
        self.menuComponent = MenuComponent()
        self.racerInputsComponent = RacerInputsComponent()
        self.racerRecommenderComponent = RacerRecommenderComponent()
    }
    
    func render(parentView: UIView) {
        self.racerInputsComponent.render(parentView: self.view)
        self.headerComponent.render(parentView: self.view)
        self.menuComponent.render(parentView: self.view)
        self.racerRecommenderComponent.render(parentView: self.view)
        parentView.addSubview(self.view)
    }
}



class Racing {
    var apiClient: RacingApiClient!
    var parentView: UIView!
    var controlPanelComponent: ControlPanelComponent!
    var racerRecommendingController: RacerRecommendingController!
    
    init(apiClient: RacingApiClient, view: UIView) {
        self.apiClient = apiClient
        self.parentView = view
        self.makeComponents()
        self.makeControllers()
    }
    
    func makeComponents () {
        self.controlPanelComponent = ControlPanelComponent()
    }

    func makeControllers () {
        self.racerRecommendingController = RacerRecommendingController(
            apiClient: self.apiClient,
            racerInputsComponent: self.controlPanelComponent.racerInputsComponent,
            racerRecommenderComponent: self.controlPanelComponent.racerRecommenderComponent
        )
    }

    func renderUI() {
        self.controlPanelComponent.render(parentView: self.parentView)
    }
}
