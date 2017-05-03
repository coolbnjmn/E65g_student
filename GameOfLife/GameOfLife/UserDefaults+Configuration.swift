//
//  UserDefaults+Configuration.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/3/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

extension UserDefaults {
    // Configuration extension
    static func checkConfigurationIsSavableAndSave(_ defaults: UserDefaults, _ newConfiguration: Configuration, fromViewController: UIViewController) {
        guard let currentConfigurations: [String: Any] = defaults.dictionary(forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey) else {
                // no existing user defaults
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration)
                return
        }
        let existingNames = Array(currentConfigurations.keys)
        
        let filteredNames = existingNames.filter {
            configurationTitle in
            return configurationTitle == newConfiguration.title
        }
        
        if filteredNames.count > 0 {
            // show alert that Configuration alraedy exists, need to pick a new name
            let replaceConfigurationHandler: ()->Void = {
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, currentConfigurations: currentConfigurations)
            }
            ConfigurationsSaveAlertController.displayNameExistsAlert(presentingViewController: fromViewController, completion: replaceConfigurationHandler)
            return
        }
        
        guard let existingConfigurations: [[[Int]]] = Array(currentConfigurations.values) as? [[[Int]]] else {
            assertionFailure("issue parsing current configurations to determine duplicates")
            return
        }
        
        let filteredConfigurations = existingConfigurations.filter {
            configurationContents in
            // use placeholder "title" because `Configuration` class == only checks contents
            return Configuration("title", withContents: configurationContents) == newConfiguration
        }
        
        if filteredConfigurations.count > 0 {
            // show alert that Configuration will override existing, different-name-but-same-content configuration
            
            return
        }
        
        UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, currentConfigurations: currentConfigurations)
    }
    
    fileprivate static func saveConfigurationTo(_ defaults: UserDefaults, configuration: Configuration, currentConfigurations: [String: Any] = [:]) {
        Configuration.encodeConfigurationToJSON(configuration, {
            dictionary in
            guard let title: String = dictionary["title"] as? String else {
                return
            }
            let anyDictionary: AnyObject = dictionary as AnyObject
            var newConfigurations = currentConfigurations
            newConfigurations[title] = anyDictionary
            defaults.set(newConfigurations, forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey)
        })
    }
}
