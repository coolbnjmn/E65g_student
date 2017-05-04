//
//  Configuration.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/1/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import Foundation

class Configuration: Equatable {
    var title: String
    var contents: [[Int]]
    
    init(_ title: String, withContents contents: [[Int]]) {
        self.title = title
        self.contents = contents
    }
}

func ==(lhs: Configuration, rhs: Configuration) -> Bool {
    guard lhs.contents.count == rhs.contents.count else {
        return false
    }
    
    for (index, lhsPosition) in lhs.contents.enumerated() {
        let rhsPosition = rhs.contents[index]
        if (rhsPosition.count != 2 || lhsPosition.count != 2) {
            return false
        }
        
        if (rhsPosition[0] != lhsPosition[0] || rhsPosition[1] != lhsPosition[1]) {
            return false
        }
    }
    
    return true
}

// MARK: - JSON Helper methods
extension Configuration {
    static func decodeJsonIntoConfigurations(_ json: Any?, _ completion: (([Configuration]) -> Void)) {
        guard let jsonArray = json as? NSArray else {
            print("json can't be casted as an array")
            return
        }
        
        var configurationArray = [Configuration]()
        
        for element in jsonArray {
            if let jsonDictionary = element as? NSDictionary,
                let configurationTitle = jsonDictionary["title"] as? String,
                let configurationContents = jsonDictionary["contents"] as? [[Int]] {
                configurationArray.append(Configuration(configurationTitle, withContents: configurationContents))
            }
        }
        
        completion(configurationArray)
    }
    
    static func decodeJsonIntoConfiguration(_ dictionary: [String: AnyObject], _ completion: ((Configuration?) -> Void)) {
        if let configurationTitle = dictionary["title"] as? String,
            let configurationContents = dictionary["contents"] as? [[Int]] {
            completion(Configuration(configurationTitle, withContents: configurationContents))
        } else {
            completion(nil)
        }
    }
    
    static func encodeConfigurationToJSON(_ configuration: Configuration, _ completion: (([String: AnyObject]) -> Void)) {
        var resultDictionary = [String: AnyObject]()
        
        resultDictionary["title"] = configuration.title as AnyObject
        resultDictionary["contents"] = configuration.contents as AnyObject
        completion(resultDictionary)
    }
}

// MARK: - Grid Helper methods
extension Configuration {
    public static func generateContentsFromGrid(_ grid: Grid) -> [[Int]] {
        let gridIterator = grid.makeIterator()
        let aliveCells = gridIterator.alive

        let contentsArray: [[Int]] = aliveCells.map {
            position in
            return [position.row, position.col]
        }
        
        return contentsArray
    }
    
    public func generateGridWithContents(_ completion: @escaping (Grid?)->Void) {
        guard contents.count > 0 else {
            assertionFailure("Configuration isn't properly set up for grid retrieval. Empty grid coming!")
            completion(nil)
            return
        }
        
        let startPositionsOptional: [GridPosition?] = contents.map {
            startPosition in
            // startPosition, from JSON format given, is a 2 element array with [row, col] format.
            guard startPosition.count == 2 else {
                return nil
            }
            return GridPosition(row: startPosition[0], col: startPosition[1])
        }
        
        var startPositions = [GridPosition]()
        var maxRow: Int = 0
        var maxCol: Int = 0
        startPositionsOptional.forEach {
            optionalPosition in
            if let position = optionalPosition {
                startPositions.append(position)
                maxRow = (position.row > maxRow) ? position.row : maxRow
                maxCol = (position.col > maxCol) ? position.col : maxCol
            }
        }
        
        let size: Int = max(maxRow, maxCol) * 2
        let grid = Grid(size, size, cellInitializer: {
            position in
            if startPositions.contains(where: {
                row, col in
                return row == position.row && col == position.col
            }) {
                return .alive
            } else {
                return .empty
            }
        })
        
        completion(grid)
    }
}
