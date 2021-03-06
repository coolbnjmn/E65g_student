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
        guard let currentConfigurations: [String: [String: AnyObject]] = defaults.value(forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey) as? [String: [String: AnyObject]] else {
                // no existing user defaults
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
                return
        }
        
        let existingNames = Array(currentConfigurations.keys)
        
        let filteredNames = existingNames.filter {
            configurationTitle in
            return configurationTitle == newConfiguration.title
        }
        
        let existingConfigurations: [[String: AnyObject]] = Array(currentConfigurations.values)
        let filteredConfigurations = existingConfigurations.filter {
            (configuration: [String: AnyObject]) in
            // use placeholder "title" because `Configuration` class == only checks contents
            guard let title = configuration["title"] as? String,
                let contents = configuration["contents"] as? [[Int]] else {
                    return false
            }
            return Configuration(title, withContents: contents) == newConfiguration
        }
        
        if filteredNames.count > 0 && filteredConfigurations.count > 0 {
            let exactMatches = filteredConfigurations.filter {
                (configuration: [String: AnyObject]) in
                if let title = configuration["title"] as? String {
                    return filteredNames.contains(title)
                }
                return false
            }
            if exactMatches.count > 0 {
                // If there is an exact match, don't ask to replace, silently save
                // this allows for easy "simulation loading" for pre-existing configurations
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
                return
            }
        }
        
        if filteredNames.count > 0 {
            // show alert that Configuration alraedy exists, need to pick a new name
            let replaceConfigurationHandler: ()->Void = {
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
            }
            ConfigurationsSaveAlertController.displayNameExistsAlert(presentingViewController: fromViewController, completion: replaceConfigurationHandler)
            return
        }
        
        if filteredConfigurations.count > 0 {
            // show alert that Configuration will duplicate existing, different-name-but-same-content configuration
            let replaceConfigurationHandler: ()->Void = {
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
            }
            ConfigurationsSaveAlertController.displayContentsExistsOverrideAlert(presentingViewController: fromViewController, completion: replaceConfigurationHandler)
            return
        }
        
        UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
    }
    
    static func saveConfigurationsFromNetwork(_ defaults: UserDefaults, configurations: [Configuration]) {
        var currentConfigurations: [String: [String: AnyObject]]
        if let rawConfigurations = getRawConfigurationsFrom(defaults) {
            currentConfigurations = rawConfigurations
        } else {
            currentConfigurations = [String: [String: AnyObject]]()
        }
        
        let dictionaries: [[String: AnyObject]] = configurations.map {
            configuration in
            return Configuration.encodeConfigurationToJSON(configuration)
        }
        let _ = dictionaries.forEach {
            dictionary in
            guard let title: String = dictionary["title"] as? String else {
                return
            }
            currentConfigurations[title] = dictionary
            return
        }
        defaults.set(currentConfigurations, forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey)
    }
    
    fileprivate static func saveConfigurationTo(_ defaults: UserDefaults, configuration: Configuration, fromViewController: UIViewController) {
        var currentConfigurations: [String: [String: AnyObject]]
        if let rawConfigurations = getRawConfigurationsFrom(defaults) {
            currentConfigurations = rawConfigurations
        } else {
            currentConfigurations = [String: [String: AnyObject]]()
        }

        let dictionary = Configuration.encodeConfigurationToJSON(configuration)
        guard let title: String = dictionary["title"] as? String else {
            return
        }
        var newConfigurations = currentConfigurations
        newConfigurations[title] = dictionary
        defaults.set(newConfigurations, forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey)
        defaults.set(dictionary, forKey: Constants.Defaults.defaultSimulationTabConfigurationUserDefaultKey)

        configuration.generateGridWithContents {
            gridOptional in
            guard let grid = gridOptional else {
                return
            }
            
            NotificationCenter.default.post(Notification(name: Constants.Notifications.configurationsChangeNotification, object: nil, userInfo: ["grid": grid]))
            DispatchQueue.main.async {
                fromViewController.navigationController?.popViewController(animated: true)
            }
        }
    }

    fileprivate static func getRawConfigurationsFrom(_ defaults: UserDefaults) -> [String: [String: AnyObject]]? {
        if let rawConfigurationDefaults = defaults.value(forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey) as? [String: [String: AnyObject]] {
            return rawConfigurationDefaults
        } else {
            return nil
        }
    }
    
    static func getAllConfigurations(_ defaults: UserDefaults = UserDefaults.standard, _ completion: (([Configuration]) -> Void)) {
        if let rawConfigurationsDefaults = defaults.value(forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey) as? [String: [String: AnyObject]] {
            let allKeys = Array(rawConfigurationsDefaults.keys)
            let configurationOptionals: [Configuration?] = allKeys.map {
                configurationTitle in
                guard let configurationDictionary = rawConfigurationsDefaults[configurationTitle],
                        let contents = configurationDictionary["contents"] as? [[Int]] else {
                    return nil
                }
                
                return Configuration(configurationTitle, withContents: contents)
            }
            var configurations = [Configuration]()
            configurationOptionals.forEach {
                configurationOptional in
                guard let configuration = configurationOptional else {
                    return
                }
                configurations.append(configuration)
            }
            
            completion(configurations)
        } else {
            completion([])
        }
    }
    
    static func removeAllConfigurations(_ defaults: UserDefaults = UserDefaults.standard) {
        // Note: this maintains the simulation tab configuration, which is purely used to load that tab at launch
        defaults.removeObject(forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey)
    }
    
    static func getSimulationTabConfiguration(_ defaults: UserDefaults = UserDefaults.standard, _ completion: ((Configuration?) -> Void)) {
        if let configurationDictionary = defaults.value(forKey: Constants.Defaults.defaultSimulationTabConfigurationUserDefaultKey) as? [String: AnyObject],
            let title = configurationDictionary["title"] as? String,
            let contents = configurationDictionary["contents"] as? [[Int]] {
            completion(Configuration(title, withContents: contents))
        } else {
            completion(nil)
        }
    }
    
    static func removeSimulationTabConfiguration(_ defaults: UserDefaults = UserDefaults.standard) {
        defaults.removeObject(forKey: Constants.Defaults.defaultSimulationTabConfigurationUserDefaultKey)
    }
}
