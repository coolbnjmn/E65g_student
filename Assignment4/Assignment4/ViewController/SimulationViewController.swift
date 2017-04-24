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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gridView.delegate = self
        StandardEngine.engine.delegate = self
        updateGridAndRedisplay()
    }
    
    @IBAction func stepButtonPressed(_ sender: Any) {
        gridView.grid = StandardEngine.engine.step()
        updateEngineAndDisplay()
    }
    
    func gridViewBasicConstraints() {
        let yCenterConstraint = NSLayoutConstraint(item: gridView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: gridView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: gridView, attribute: .height, relatedBy: .equal, toItem: gridView, attribute: .width, multiplier: 1.0, constant: 0)
        
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        yCenterConstraint.isActive = true
        
        let stepTopConstraint = NSLayoutConstraint(item: stepButton, attribute: .top, relatedBy: .equal, toItem: gridView, attribute: .bottom, multiplier: 1.0, constant: 12)
        stepTopConstraint.isActive = true
    }
    
    func updateGridAndRedisplay() {
        print("++++ gridSize: \(StandardEngine.engine.grid.size)")
        gridView.grid = StandardEngine.engine.grid
        gridView.size = gridView.grid.size.rows
        
        gridView.removeFromSuperview()
        view.addSubview(gridView)
        gridViewBasicConstraints()
        gridView.updateConstraints()
        gridView.layoutSubviews()
        
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
