//
//  GridEditorViewController.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 03/05/2017.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, StoryboardIdentifiable {

    var gridConfiguration: Configuration? {
        didSet {
            view.setNeedsDisplay()
        }
    }

    private(set) var gridLoaded: Bool = false

    @IBOutlet weak var gridNameTextField: UITextField!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        GridEditorEngine.engine.delegate = self
        gridView.origin = .instrumentation
        if let gridConfiguration = gridConfiguration {
            gridConfiguration.generateGridWithContents {
                [weak self]
                gridOptional in
                guard let grid = gridOptional,
                    let strongSelf = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.gridLoaded = true
                    GridEditorEngine.engine.grid = grid
                }
            }
            gridNameTextField.text = gridConfiguration.title
        } else {
            gridLoaded = true
            GridEditorEngine.engine.grid = Grid(StandardEngine.engine.rows, StandardEngine.engine.cols)
        }
        gridNameTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        if !gridLoaded && animated {
            startLoadIndicator()
        }
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gridView.delegate = self
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gridView?.setNeedsDisplay()
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let grid = GridEditorEngine.engine.grid as? Grid,
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

    func startLoadIndicator() {
        gridView.alpha = 0
        loadingActivityIndicator.alpha = 1
        loadingActivityIndicator.startAnimating()
    }

    func stopLoadIndicator() {
        loadingActivityIndicator.stopAnimating()
        gridView.alpha = 1
        loadingActivityIndicator.alpha = 0
    }
}

extension GridEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension GridEditorViewController: GridViewDelegate {
    func cellStateChanged(_ position: (Int, Int), newState: CellState) {
        let _ = GridEditorEngine.engine.gridCellStateChange(position, newState)
    }
}

extension GridEditorViewController: EngineDelegate {
    func engineDidUpdate(withGrid gridFromEngine: GridProtocol, forceUpdate: Bool = false) {
        gridView.setNeedsDisplay()
        // grid editor doesn't send stats to Statistics view, only Simulation does.
        if loadingActivityIndicator.isAnimating {
            stopLoadIndicator()
        }
    }
}
