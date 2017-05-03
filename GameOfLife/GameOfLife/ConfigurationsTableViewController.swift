//
//  ConfigurationsController.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 5/2/17.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

class ConfigurationsTableViewController: UIViewController {
    @IBOutlet weak var configurationsTableView: UITableView!
    
    lazy var configurationsDataSource: ConfigurationsDataSource = {
        return ConfigurationsDataSource(tableView: self.configurationsTableView) // uses default url
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationsTableView.dataSource = configurationsDataSource
    }
}

extension ConfigurationsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let configurationOptional: Configuration? = configurationsDataSource.configurationForIndexPath(indexPath)
        guard let configuration = configurationOptional else {
            assertionFailure("No configuration for tapped row, this should never occur.")
            return
        }

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let gridEditorViewController = mainStoryboard.instantiateViewController(withIdentifier: GridEditorViewController.storyboardIdentifier) as? GridEditorViewController else {
            assertionFailure("Could not properly instantiate a grid editor view controller")
            return
        }

        gridEditorViewController.gridConfiguration = configuration
        // this view controller is embedded inside instrumentation, so we want instrumentation to push the VC...
        parent?.navigationController?.pushViewController(gridEditorViewController, animated: true)
    }
}
