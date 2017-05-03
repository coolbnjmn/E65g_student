//
//  GridEditorViewController.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 03/05/2017.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, StoryboardIdentifiable {

    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var saveButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        GridEditorEngine.engine.delegate = self
        gridView.origin = .instrumentation
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
        // let gridNotification: NSNotification.Name = NSNotification.Name(rawValue: Constants.Strings.gridChangeNotification)
        // NotificationCenter.default.post(Notification(name: gridNotification, object: nil, userInfo: ["grid": gridView.grid]))
    }
}
