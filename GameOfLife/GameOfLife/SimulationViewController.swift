//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, StoryboardIdentifiable {

    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var stepButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var gridNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StandardEngine.engine.delegate = self
        gridNameTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gridView.delegate = self
        stepButton.isEnabled = (StandardEngine.engine.refreshRate == 0)
        saveButton.isEnabled = (StandardEngine.engine.refreshRate == 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gridView?.setNeedsDisplay()
    }
    
    @IBAction func stepButtonPressed(_ sender: Any) {
        let _ = StandardEngine.engine.step()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Ideally this isn't duplicated, but will leave for now. Could move to UserDefaults extension.
        guard let grid = StandardEngine.engine.grid as? Grid,
            let gridName = gridNameTextField.text else {
                return
        }
        
        if gridName.characters.count == 0 {
            let alertController = UIAlertController(title: "Please name the grid", message: "Grid names need at least a char", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        if grid.makeIterator().alive.count == 0 {
            let alertController = UIAlertController(title: "Please add live cells to the grid", message: "Saved grids need one alive cell", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let contents = Configuration.generateContentsFromGrid(grid)
            let possibleNewConfiguration = Configuration(gridName, withContents: contents)
            UserDefaults.checkConfigurationIsSavableAndSave(UserDefaults.standard, possibleNewConfiguration, fromViewController: self)
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        StandardEngine.engine.clearCurrentGrid()
        UserDefaults.removeSimulationTabConfiguration()
    }
    
    @IBAction func videoButtonPressed(_ sender: Any) {
        guard let grid = gridView.grid as? Grid else {
            return
        }
        VideoExportController.makeVideoFromGrid(grid, withDesiredLength: 10, andRefreshRate: StandardEngine.engine.refreshRate) {
            documentController in
            documentController?.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        }
    }
}

extension SimulationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SimulationViewController: GridViewDelegate {
    func cellStateChanged(_ position: (Int, Int), newState: CellState) {
        let _ = StandardEngine.engine.gridCellStateChange(position, newState)
    }
}

extension SimulationViewController: EngineDelegate {
    func engineDidUpdate(withGrid gridFromEngine: GridProtocol, forceUpdate: Bool = false) {
        DispatchQueue.main.async {
            self.gridView.setNeedsDisplay()
            if forceUpdate {
                self.view.layoutIfNeeded()
            }
        }
        NotificationCenter.default.post(Notification(name: Constants.Notifications.gridChangeNotification, object: nil, userInfo: ["grid": gridView.grid]))
    }
}
