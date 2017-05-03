//
//  StoryboardIdentifiable.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 03/05/2017.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable {
    var storyboardIdentifier: String {
        return String(describing: type(of: self))
    }
}
