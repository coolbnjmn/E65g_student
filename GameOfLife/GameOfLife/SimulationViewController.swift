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
        NotificationCenter.default.post(Notification(name: Constants.Notifications.gridChangeNotification, object: nil, userInfo: ["grid": gridView.grid]))
    }
}
