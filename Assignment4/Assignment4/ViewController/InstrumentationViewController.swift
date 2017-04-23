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
    }

    // MARK :- IBActions

    @IBAction func rowTextFieldChanged(_ sender: Any) {
        rowStepper.value = Double(rowTextField.text ?? "") ?? rowStepper.value
    }
    
    @IBAction func rowStepperPressed(_ sender: Any) {
        rowTextField.text = "\(rowStepper.value)"
    }

    @IBAction func colTextFieldChanged(_ sender: Any) {
        colStepper.value = Double(colTextField.text ?? "") ?? colStepper.value
    }
    
    @IBAction func colStepperPressed(_ sender: Any) {
        colTextField.text = "\(colStepper.value)"
    }
    
    @IBAction func refreshRateTextFieldChanged(_ sender: Any) {
        refreshRateSlider.value = Float(refreshRateTextField.text ?? "") ?? refreshRateSlider.value
    }

    @IBAction func refreshRateSliderSlid(_ sender: Any) {
        refreshRateTextField.text = "\(refreshRateSlider.value)"
    }
    
    @IBAction func timedRefreshSwitchSwitched(_ sender: Any) {
    }
}

