//
//  Constants.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

public struct Constants {

    public struct Strings {
        static let gridChangeNotification: String = "Grid Changed Notification"
    }
    
    public struct Defaults {
        static let defaultColCount: Int = 10
        static let defaultRowCount: Int = 10
        static let defaultDataURL: String = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"
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
