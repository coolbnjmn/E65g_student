//
//  StandardEngine.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

class StandardEngine: EngineProtocol {
    var delegate: EngineDelegate?
    var actualGrid: GridProtocol?
    lazy var grid: GridProtocol = {
        if let grid = self.actualGrid {
            return grid
        } else {
            let newGrid = Grid(self.rows, self.cols) { row, col in .empty }
            self.actualGrid = newGrid
            return newGrid
        }
    }()
    
    var refreshRate: Double = 0 {
        didSet {
            if refreshRate > 0.0 {
                refreshTimer = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    _ = self.step()
                }
            }
            else {
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }
    var refreshTimer: Timer?
    var rows: Int = 10
    var cols: Int = 10
    
    public static let engine: StandardEngine = StandardEngine()

    required init() {
        rows = 10
        cols = 10
        refreshTimer = Timer()
    }

    func step() -> GridProtocol {
        grid = grid.next()
        delegate?.engineDidUpdate(withGrid: grid)
        return grid
    }

}
