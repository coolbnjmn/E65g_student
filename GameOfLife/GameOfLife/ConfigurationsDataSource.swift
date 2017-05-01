//
//  ConfigurationsDataSource.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/1/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import Foundation

class ConfigurationsDataSource {
    var configurations: [Configuration]? = nil
    
    init(_ dataSourceUrlString: String = Constants.Defaults.defaultDataURL) {
        NetworkManager.shared.fetchDataFromURL(dataSourceUrlString) {
            success, json in
            if success {
                Configuration.decodeJsonIntoConfigurations(json) {
                    configurationArray in
                    self.configurations = configurationArray
                }
            } else {
                self.configurations = nil
            }
        }
    }
}
