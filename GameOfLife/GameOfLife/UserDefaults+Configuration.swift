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
    static func checkConfigurationIsSavableAndSave(_ defaults: UserDefaults, _ newConfiguration: Configuration, fromViewController: UIViewController, skipChecks: Bool = false) {
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
        
        if !skipChecks && filteredNames.count > 0 {
            // show alert that Configuration alraedy exists, need to pick a new name
            let replaceConfigurationHandler: ()->Void = {
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
            }
            ConfigurationsSaveAlertController.displayNameExistsAlert(presentingViewController: fromViewController, completion: replaceConfigurationHandler)
            return
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
        
        if !skipChecks && filteredConfigurations.count > 0 {
            // show alert that Configuration will override existing, different-name-but-same-content configuration
            let replaceConfigurationHandler: ()->Void = {
                UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
            }
            ConfigurationsSaveAlertController.displayContentsExistsOverrideAlert(presentingViewController: fromViewController, completion: replaceConfigurationHandler)
            return
        }
        
        UserDefaults.saveConfigurationTo(defaults, configuration: newConfiguration, fromViewController: fromViewController)
    }
    
    fileprivate static func saveConfigurationTo(_ defaults: UserDefaults, configuration: Configuration, fromViewController: UIViewController) {
        var currentConfigurations: [String: [String: AnyObject]]
        if let rawConfigurations = getRawConfigurationsFrom(defaults) {
            currentConfigurations = rawConfigurations
        } else {
            currentConfigurations = [String: [String: AnyObject]]()
        }

        Configuration.encodeConfigurationToJSON(configuration, {
            (dictionary: [String: AnyObject]) in
            guard let title: String = dictionary["title"] as? String else {
                return
            }
            var newConfigurations = currentConfigurations
            newConfigurations[title] = dictionary
            defaults.set(newConfigurations, forKey: Constants.Defaults.defaultConfigurationsUserDefaultsKey)
            defaults.set(dictionary, forKey: Constants.Defaults.defaultSimulationTabConfigurationUserDefaultKey)
        })
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
    
    static func getSimulationTabConfiguration(_ defaults: UserDefaults = UserDefaults.standard, _ completion: ((Configuration?) -> Void)) {
        if let configurationDictionary = defaults.value(forKey: Constants.Defaults.defaultSimulationTabConfigurationUserDefaultKey) as? [String: AnyObject],
            let title = configurationDictionary["title"] as? String,
            let contents = configurationDictionary["contents"] as? [[Int]] {
            completion(Configuration(title, withContents: contents))
        } else {
            completion(nil)
        }
    }
}
