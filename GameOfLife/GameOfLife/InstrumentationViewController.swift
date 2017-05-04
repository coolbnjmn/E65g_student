//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController, StoryboardIdentifiable {

    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var colLabel: UILabel!

    @IBOutlet weak var rowNumberLabel: UILabel!
    @IBOutlet weak var colNumberLabel: UILabel!

    
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var sizeSlider: UISlider!
   
    @IBOutlet weak var refreshRateLabel: UILabel!
    @IBOutlet weak var refreshRateNumberLabel: UILabel!
    @IBOutlet weak var refreshRateSlider: UISlider!
    
    @IBOutlet weak var timedRefreshSwitch: UISwitch!
    
    @IBOutlet weak var topLevelStackView: UIStackView!
    @IBOutlet weak var configurationsContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    func setupUI() {
        
        rowNumberLabel.text = "\(Int(sizeStepper.value))"
        colNumberLabel.text = "\(Int(sizeStepper.value))"

        // Shown in navigation controller's automatic "back" handling
        navigationItem.title = "Instrumentation"
    }
    
    func updateGridSize() {
        StandardEngine.engine.rows = Int(sizeStepper.value)
        StandardEngine.engine.cols = Int(sizeStepper.value)
    }

    // MARK :- IBActions
    @IBAction func sizeStepperPressed(_ sender: Any) {
        let newValue: Int = Int(sizeStepper.value)
        rowNumberLabel.text = "\(newValue)"
        colNumberLabel.text = rowNumberLabel.text
        sizeSlider.value = Float(newValue)
        updateGridSize()
    }
    
    @IBAction func sizeSliderSlid(_ sender: Any) {
        let newValue: Int = Int(sizeSlider.value)
        rowNumberLabel.text = "\(newValue)"
        colNumberLabel.text = rowNumberLabel.text
        sizeStepper.value = Double(newValue)
    }
    
    @IBAction func sizeSliderFinishedSliding(_ sender: Any) {
        updateGridSize()
    }

    @IBAction func refreshRateSliderSlid(_ sender: Any) {
        refreshRateNumberLabel.text = "\(refreshRateSlider.value.roundTo(2))"
        StandardEngine.engine.refreshRate = 1/(Double(refreshRateNumberLabel.text ?? "\(refreshRateSlider.value.roundTo(2))") ?? (Double(refreshRateSlider.value.roundTo(2))))
    }
    
    @IBAction func timedRefreshSwitchSwitched(_ sender: Any) {
        if let timerSwitch = sender as? UISwitch {
            if timerSwitch.isOn {
                // start timer
                StandardEngine.engine.refreshRate = 1/(Double(refreshRateSlider.value))
            } else {
                StandardEngine.engine.refreshRate = 0
            }
            refreshRateSlider.isEnabled = timerSwitch.isOn
        }
    }
    
    @IBAction func addConfigurationPressed(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let gridEditorViewController = mainStoryboard.instantiateViewController(withIdentifier: GridEditorViewController.storyboardIdentifier) as? GridEditorViewController else {
            assertionFailure("Could not properly instantiate a grid editor view controller")
            return
        }
        navigationController?.pushViewController(gridEditorViewController, animated: true)
    }
    
}

