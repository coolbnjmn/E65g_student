//
//  StandardEngine.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

class StandardEngine: EngineProtocol {

    public static let engine: StandardEngine = StandardEngine()

    var delegate: EngineDelegate?
    
    private(set) var grid: GridProtocol {
        didSet {
            self.delegate?.engineDidUpdate(withGrid: self.grid)
        }
    }
    
    var refreshTimer: Timer?
    var refreshRate: Double = 0 {
        didSet {
            if refreshTimer != nil {
                refreshTimer?.invalidate()
            }
            
            if refreshRate > 0.0 {
                refreshTimer = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    self.grid = self.step()
                }
            } else {
                refreshTimer = nil
            }
        }
    }
    
    // For now always maintain square grid, as mentioned in Canvas discussion
    var rows: Int = Constants.Defaults.defaultRowCount {
        didSet {
            if rows != oldValue {
                cols = rows
                gridSizeChanged(oldValue)
            }
        }
    }
    var cols: Int = Constants.Defaults.defaultColCount {
        didSet {
            if cols != rows {
                rows = cols
            }
        }
    }
    
    required init() {
        grid = Grid(self.rows, self.cols) { row, col in .empty }
        rows = Constants.Defaults.defaultRowCount
        cols = Constants.Defaults.defaultColCount
        NotificationCenter.default.addObserver(self, selector: #selector(StandardEngine.configurationSaved(_:)), name: Constants.Notifications.configurationsChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func step() -> GridProtocol {
        grid = grid.next()
        return grid
    }
    
    func gridCellStateChange(_ position: (Int, Int), _ newCellState: CellState) -> GridProtocol {
        grid[position] = newCellState
        delegate?.engineDidUpdate(withGrid: grid)
        return grid
    }
    
    @objc func configurationSaved(_ notification: Notification) {
        guard let newGrid = notification.userInfo?["grid"] as? Grid else {
            return
        }
        
        self.grid = newGrid
        self.rows = newGrid.size.rows
        delegate?.engineDidUpdate(withGrid: newGrid)
    }
    
    // Helpers
    func gridSizeChanged(_ oldValue: Int) {
        let newGrid = Grid(rows, cols) {
            row, col in

            if (row < oldValue-1) && (col < oldValue-1) {
                return (self.grid[(row,col)])
            } else {
                return .empty
            }
        }
        let refreshRateCache = self.refreshRate
        // set to 0 while changing grid size to stop timer reload race conditions
        self.refreshRate = 0
        self.grid = newGrid
        self.refreshRate = refreshRateCache
    }
}
