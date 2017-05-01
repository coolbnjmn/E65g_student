//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {
    static let storyboardID: String = "InstrumentationViewController"

    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var rowTextField: UITextField!
    @IBOutlet weak var rowStepper: UIStepper!
    
    @IBOutlet weak var colLabel: UILabel!
    @IBOutlet weak var colTextField: UITextField!
    @IBOutlet weak var colStepper: UIStepper!
   
    @IBOutlet weak var refreshRateLabel: UILabel!
    @IBOutlet weak var refreshRateTextField: UITextField!
    @IBOutlet weak var refreshRateKeyFirstLabel: UILabel!
    @IBOutlet weak var refreshRateKeySecondLabel: UILabel!
    @IBOutlet weak var refreshRateKeyImageView: UIImageView!
    @IBOutlet weak var refreshRateSlider: UISlider!
    
    @IBOutlet weak var timedRefreshLabel: UILabel!
    @IBOutlet weak var timedRefreshSwitch: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        refreshRateKeyImageView.image = #imageLiteral(resourceName: "keyIcon").withRenderingMode(.alwaysTemplate)
        refreshRateKeyImageView.tintColor = Constants.Colors.appRedColor
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        
        rowTextField.text = "\(rowStepper.value)"
        colTextField.text = "\(colStepper.value)"
    }
    
    func updateGridSize() {
        StandardEngine.engine.rows = Int(rowStepper.value)
        StandardEngine.engine.cols = Int(colStepper.value)
    }

    // MARK :- IBActions
    @IBAction func rowTextFieldChanged(_ sender: Any) {
        let newValue = Double(Int(((Double(rowTextField.text ?? "") ?? rowStepper.value)*100).rounded()/100))
        
        guard newValue <= 1000 && newValue >= 2 else {
            rowTextField.shakeAndWiggle()
            rowTextField.becomeFirstResponder()
            return
        }
        
        rowStepper.value = Double(Int(Double(rowTextField.text ?? "") ?? rowStepper.value))
        colStepper.value = rowStepper.value
        colTextField.text = rowTextField.text
        updateGridSize()
    }
    
    @IBAction func rowStepperPressed(_ sender: Any) {
        rowTextField.text = "\(rowStepper.value)"
        colStepper.value = rowStepper.value
        colTextField.text = rowTextField.text
        updateGridSize()
    }

    @IBAction func colTextFieldChanged(_ sender: Any) {
        let newValue = Double(Int(((Double(colTextField.text ?? "") ?? colStepper.value)*100).rounded()/100))
        
        guard newValue <= 1000 && newValue >= 2 else {
            colTextField.shakeAndWiggle()
            colTextField.becomeFirstResponder()
            return
        }

        colStepper.value = Double(Int(Double(colTextField.text ?? "") ?? colStepper.value))
        rowStepper.value = colStepper.value
        rowTextField.text = colTextField.text
        updateGridSize()
    }
    
    @IBAction func colStepperPressed(_ sender: Any) {
        colTextField.text = "\(colStepper.value)"
        rowStepper.value = colStepper.value
        rowTextField.text = colTextField.text
        updateGridSize()
    }
    
    @IBAction func refreshRateTextFieldChanged(_ sender: Any) {
        let newValue = ((Float(refreshRateTextField.text ?? "") ?? refreshRateSlider.value)*100).rounded()/100
        
        guard newValue <= 10 && newValue >= 0.1 else {
            refreshRateTextField.shakeAndWiggle()
            refreshRateTextField.becomeFirstResponder()
            return
        }
        refreshRateSlider.value = newValue
    }

    @IBAction func refreshRateSliderSlid(_ sender: Any) {
        refreshRateTextField.text = "\((refreshRateSlider.value*100).rounded()/100)"
        StandardEngine.engine.refreshRate = 1/(Double(refreshRateTextField.text ?? "\((refreshRateSlider.value*100).rounded()/100)") ?? (Double((refreshRateSlider.value*100).rounded())/100))
    }
    
    @IBAction func timedRefreshSwitchSwitched(_ sender: Any) {
        if let timerSwitch = sender as? UISwitch {
            if timerSwitch.isOn {
                // start timer
                StandardEngine.engine.refreshRate = 1/(Double(refreshRateSlider.value))
            } else {
                StandardEngine.engine.refreshRate = 0
            }
        }
    }
}

