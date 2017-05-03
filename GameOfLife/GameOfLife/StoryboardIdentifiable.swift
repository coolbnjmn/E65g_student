//
//  StoryboardIdentifiable.swift
//  GameOfLife
//
//  Created by Benjamin Hendricks on 03/05/2017.
//  Copyright © 2017 coolbnjmn. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}
