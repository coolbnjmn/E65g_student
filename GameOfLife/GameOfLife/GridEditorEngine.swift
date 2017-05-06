//
//  GridEditorEngine.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 03/05/2017.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit


protocol EditorEngineProtocol {
    var grid: GridProtocol { get set }
    var delegate: EngineDelegate? { get set }
}

class GridEditorEngine: EditorEngineProtocol {
    public static let engine: GridEditorEngine = GridEditorEngine()
    public static let videoEngine: GridEditorEngine = GridEditorEngine()

    var delegate: EngineDelegate?

    public var grid: GridProtocol {
        didSet {
            self.delegate?.engineDidUpdate(withGrid: self.grid, forceUpdate: false)
        }
    }

    func gridCellStateChange(_ position: (Int, Int), _ newCellState: CellState) -> GridProtocol {
        grid[position] = newCellState
        delegate?.engineDidUpdate(withGrid: grid, forceUpdate: false)
        return grid
    }

    required init() {
        grid = Grid(Constants.Defaults.defaultRowCount, Constants.Defaults.defaultColCount)
    }
}
