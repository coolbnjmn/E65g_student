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
        gridView.delegate = self
        StandardEngine.engine.delegate = self
        updateEngineAndDisplay()
    }
    
    @IBAction func stepButtonPressed(_ sender: Any) {
        gridView.grid = StandardEngine.engine.step()
        updateEngineAndDisplay()
    }
    
    func updateEngineAndDisplay() {
        StandardEngine.engine.grid = gridView.grid
        StandardEngine.engine.delegate?.engineDidUpdate(withGrid: gridView.grid)
        gridView.setNeedsDisplay()
    }
}

extension SimulationViewController: GridViewDelegate {
    func cellStatesChanged() {
        updateEngineAndDisplay()
    }
}

extension SimulationViewController: EngineDelegate {
    func engineDidUpdate(withGrid gridFromEngine: GridProtocol) {
        gridView.grid = gridFromEngine
        let gridNotification: NSNotification.Name = NSNotification.Name(rawValue: Constants.Strings.gridChangeNotification)
        NotificationCenter.default.post(Notification(name: gridNotification, object: nil, userInfo: ["grid": gridView.grid]))
    }
}
