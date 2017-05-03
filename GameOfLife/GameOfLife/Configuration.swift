//
//  Configuration.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/1/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import Foundation

class Configuration {
    var title: String
    var contents: [[Int]]
    
    init(_ title: String, withContents contents: [[Int]]) {
        self.title = title
        self.contents = contents
    }
}

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
}

extension Configuration {
    public func generateGridWithContents() -> Grid {
        guard contents.count > 0 else {
            assertionFailure("Configuration isn't properly set up for grid retrieval. Empty grid coming!")
            return Grid(Constants.Defaults.defaultRowCount, Constants.Defaults.defaultColCount)
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
        startPositionsOptional.forEach {
            optionalPosition in
            if let position = optionalPosition {
                startPositions.append(position)
            }
        }

        let size = startPositions.count
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
        return grid
    }
}
