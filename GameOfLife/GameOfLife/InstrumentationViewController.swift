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
        NotificationCenter.default.addObserver(self, selector: #selector(InstrumentationViewController.engineDidUpdate(_:)), name: Constants.Notifications.gridChangeNotification, object: nil)
        setupUI()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        rowNumberLabel.text = "\(StandardEngine.engine.rows)"
        colNumberLabel.text = "\(StandardEngine.engine.cols)"
        sizeStepper.value = Double(StandardEngine.engine.rows)
        sizeSlider.value = Float(StandardEngine.engine.rows)

        // Shown in navigation controller's automatic "back" handling
        navigationItem.title = "Instrumentation"
    }
    
    func updateGridSize() {
        StandardEngine.engine.rows = Int(sizeStepper.value)
        StandardEngine.engine.cols = Int(sizeStepper.value)
    }
    
    func engineDidUpdate(_ notification: Notification) {
        guard let grid = notification.userInfo?["grid"] as? Grid else {
            return
        }

        if grid.size.rows != Int(sizeStepper.value) {
            rowNumberLabel.text = "\(grid.size.rows)"
            colNumberLabel.text = rowNumberLabel.text
            sizeSlider.value = Float(grid.size.rows)
            sizeStepper.value = Double(grid.size.rows)
        }
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

