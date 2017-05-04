//
//  ConfigurationsDataSource.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/1/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

class ConfigurationsDataSource: NSObject {
    var configurations: [Configuration]? = nil
    weak var tableView: UITableView?
    
    init(_ dataSourceUrlString: String = Constants.Defaults.defaultDataURL, tableView: UITableView, viewController: UIViewController) {
        super.init()
        self.tableView = tableView
        NetworkManager.shared.fetchDataFromURL(dataSourceUrlString) {
            success, json in
            if success {
                Configuration.decodeJsonIntoConfigurations(json) {
                    configurationArray in
                    configurationArray.forEach {
                        configuration in
                        UserDefaults.checkConfigurationIsSavableAndSave(UserDefaults.standard, configuration, fromViewController: viewController, skipChecks: true)
                    }
                    self.getAllAndReloadTable()
                }
            } else {
                self.configurations = nil
            }
        }
        getAllAndReloadTable()
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurationsDataSource.configurationsDidUpdate), name: Constants.Notifications.configurationsChangeNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func getAllAndReloadTable() {
        UserDefaults.getAllConfigurations {
            configurations in
            self.configurations = configurations
            self.tableView?.reloadData()
        }
    }

    public func configurationForIndexPath(_ indexPath: IndexPath) -> Configuration? {
        guard (configurations?.count ?? 0) > indexPath.row,
            let configuration: Configuration = configurations?[indexPath.row] else {
                assertionFailure("error, no configuration for this requested index path")
                return nil
        }
        return configuration
    }

    func configurationsDidUpdate() {
        getAllAndReloadTable()
    }
}

extension ConfigurationsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configurations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard (configurations?.count ?? 0) > indexPath.row,
            let configuration: Configuration = configurations?[indexPath.row] else {
            assertionFailure("error, no configuration for this cell index path")
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "configurationCell", for: indexPath)
        cell.textLabel?.text = configuration.title
        return cell
    }
    
/*
     Delegate placeholders for further development, only implementing required methods first.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // TODO: Remove if I don't implement advanced feature idea with sections.
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
    }
*/
}
