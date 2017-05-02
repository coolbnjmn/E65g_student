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
    
    var configurationsDataSource = ConfigurationsDataSource() // uses default url
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationsTableView.dataSource = configurationsDataSource
    }
}

extension ConfigurationsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
