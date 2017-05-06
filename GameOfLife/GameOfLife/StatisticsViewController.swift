//
//  StatisticsViewController.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, StoryboardIdentifiable {

    @IBOutlet weak var aliveLabel: UILabel!
    @IBOutlet weak var aliveCountLabel: UILabel!

    @IBOutlet weak var deadLabel: UILabel!
    @IBOutlet weak var deadCountLabel: UILabel!

    @IBOutlet weak var bornLabel: UILabel!
    @IBOutlet weak var bornCountLabel: UILabel!
    
    @IBOutlet weak var emptyCountLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StatisticsViewController.engineDidUpdate(_:)), name: Constants.Notifications.gridChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StatisticsViewController.engineDidUpdate(_:)), name: Constants.Notifications.gridResetNotification, object: nil)
        
        aliveLabel.text = "# Cells that are alive:"
        deadLabel.text = "# Cells that are dead:"
        bornLabel.text = "# Cells that were just born:"
        emptyLabel.text = "# Cells that are empty:"
        
        guard let grid: Grid = StandardEngine.engine.grid as? Grid else {
            return
        }
        
        let gridIterator = grid.makeIterator()
        let newAliveCount: Int = (Int(aliveCountLabel.text ?? "") ?? 0) + gridIterator.alive.count
        aliveCountLabel.text = "\(newAliveCount)"
        let newDeadCount: Int = (Int(deadCountLabel.text ?? "") ?? 0) + gridIterator.dead.count
        deadCountLabel.text = "\(newDeadCount)"
        let newBornCount: Int = (Int(bornCountLabel.text ?? "") ?? 0) + gridIterator.born.count
        bornCountLabel.text = "\(newBornCount)"
        let newEmptyCount: Int = (Int(emptyCountLabel.text ?? "") ?? 0) + gridIterator.empty.count
        emptyCountLabel.text = "\(newEmptyCount)"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func engineDidUpdate(_ notification: Notification) {
        guard let grid = notification.userInfo?["grid"] as? Grid else {
            return
        }
        
        let gridIterator = grid.makeIterator()
        let newAliveCount: Int = (Int(aliveCountLabel.text ?? "") ?? 0) + gridIterator.alive.count
        aliveCountLabel.text = "\(newAliveCount)"
        let newDeadCount: Int = (Int(deadCountLabel.text ?? "") ?? 0) + gridIterator.dead.count
        deadCountLabel.text = "\(newDeadCount)"
        let newBornCount: Int = (Int(bornCountLabel.text ?? "") ?? 0) + gridIterator.born.count
        bornCountLabel.text = "\(newBornCount)"
        let newEmptyCount: Int = (Int(emptyCountLabel.text ?? "") ?? 0) + gridIterator.empty.count
        emptyCountLabel.text = "\(newEmptyCount)"
        
        view.setNeedsDisplay()
    }
}
