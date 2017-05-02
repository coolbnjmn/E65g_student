//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController {
    static let storyboardID: String = "SimulationViewController"

    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var stepButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        StandardEngine.engine.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gridView.delegate = self
        stepButton.isEnabled = (StandardEngine.engine.refreshRate == 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gridView?.setNeedsDisplay()
    }
    
    @IBAction func stepButtonPressed(_ sender: Any) {
        let _ = StandardEngine.engine.step()
    }
}

extension SimulationViewController: GridViewDelegate {
    func cellStateChanged(_ position: (Int, Int), newState: CellState) {
        let _ = StandardEngine.engine.gridCellStateChange(position, newState)
    }
}

extension SimulationViewController: EngineDelegate {
    func engineDidUpdate(withGrid gridFromEngine: GridProtocol) {
        gridView.setNeedsDisplay()
        let gridNotification: NSNotification.Name = NSNotification.Name(rawValue: Constants.Strings.gridChangeNotification)
        NotificationCenter.default.post(Notification(name: gridNotification, object: nil, userInfo: ["grid": gridView.grid]))
    }
}
