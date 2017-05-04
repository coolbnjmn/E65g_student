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

                GridEditorEngine.engine.grid = grid
                strongSelf.gridLoaded = true
            }
        }
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
            let gridConfiguration = gridConfiguration else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let contents = Configuration.generateContentsFromGrid(grid)
            let possibleNewConfiguration = Configuration(gridConfiguration.title, withContents: contents)
            UserDefaults.checkConfigurationIsSavableAndSave(UserDefaults.standard, possibleNewConfiguration, fromViewController: self)
            DispatchQueue.main.async {
                navigationController?.popViewController(animated: true)
            }
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


extension GridEditorViewController: GridViewDelegate {
    func cellStateChanged(_ position: (Int, Int), newState: CellState) {
        let _ = GridEditorEngine.engine.gridCellStateChange(position, newState)
    }
}

extension GridEditorViewController: EngineDelegate {
    func engineDidUpdate(withGrid gridFromEngine: GridProtocol) {
        gridView.setNeedsDisplay()
        // grid editor doesn't send stats to Statistics view, only Simulation does.
        if loadingActivityIndicator.isAnimating {
            stopLoadIndicator()
        }
    }
}
