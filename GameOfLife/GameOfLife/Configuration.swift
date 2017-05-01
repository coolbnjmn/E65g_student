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
