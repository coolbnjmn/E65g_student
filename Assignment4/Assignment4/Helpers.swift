//
//  Helpers.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

extension String {
    func hexToUIColor() -> UIColor? {
        guard self.characters.count == 6 || self.characters.count == 7 else {
            // if not a hex then shouldn't attempt to make a color
            // hex is 6 chars, optionally prefixed by '#' hash-symbol.
            return nil
        }
        
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#") && self.characters.count == 7) {
            cString.remove(at: cString.startIndex)
        }
        
        guard cString.characters.count == 6 else {
            // malformed hex with 5 chars + hash caught here
            return nil
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
