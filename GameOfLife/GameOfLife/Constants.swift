//
//  Constants.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

public struct Constants {

    public struct Notifications {
        static let gridChangeNotification: Notification.Name = Notification.Name(Strings.gridChangeNotificationString)
        static let configurationsChangeNotification: Notification.Name = Notification.Name(Strings.configurationsChangeNotificationString)
        static let gridResetNotification: Notification.Name = Notification.Name(Strings.gridResetNotificationString)
    }

    public struct Strings {
        static let gridChangeNotificationString: String = "Grid Changed Notification"
        static let configurationsChangeNotificationString: String = "Configurations Changed Notification"
        static let gridResetNotificationString: String = "Grid Reset Notification"
        static let configurationExistsAlertTitle: String = "Replace existing?"
        static let configurationExistsDuplicateAlertTitle: String = "Add anyways?"
        static let configurationExistsAlertMessage: String = "Configuration exists with same name"
        static let displayContentsExistsOverrideAlertMessage: String = "Configuration exists with same contents"
        static let configurationExistsReplaceConfirmButtonTitle: String = "Replace"
        static let cancelString: String = "Cancel"
        static let yesString: String = "Yes"
        static let areYouSureString: String = "Are you sure?"
        static let resetConfigurationsMessageString: String = "This will remove all non-network fetched configurations and edits"
    }
    
    public struct Defaults {
        static let defaultConfigurationsUserDefaultsKey: String = "defaults.configurations"
        static let defaultSimulationTabConfigurationUserDefaultKey: String = "defaults.simulation_tab.configuration"
        static let defaultColCount: Int = 10
        static let defaultRowCount: Int = 10
        static let defaultDataURL: String = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"
        static let defaultGridLineWidth: CGFloat = 2.0
    }
    
    public struct Palette {
        static let appBlueColorHex: String = "2DC7FF"
        static let appYellowColorHex: String = "E8E288"
        static let appRedColorHex: String = "FF8360"
        static let appDarkGreenColorHex: String = "7DCE82"
        static let appLightGreenColorHex: String = "B9F18C"
    }
    
    public struct Colors {
        static let appBlueColor: UIColor = Constants.Palette.appBlueColorHex.hexToUIColor() ?? UIColor.blue
        static let appYellowColor: UIColor = Constants.Palette.appYellowColorHex.hexToUIColor() ?? UIColor.yellow
        static let appRedColor: UIColor = Constants.Palette.appRedColorHex.hexToUIColor() ?? UIColor.red
        static let appDarkGreenColor: UIColor = Constants.Palette.appDarkGreenColorHex.hexToUIColor() ?? UIColor.green
        static let appLightGreenColor: UIColor = Constants.Palette.appLightGreenColorHex.hexToUIColor() ?? UIColor.orange
    }
    
}
