//
//  EngineProtocol.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    
    init()
    init(rowCount: Int, colCount: Int)
    func step() -> GridProtocol
    func setupEngineFromConfiguration(_ configuration: Configuration)
    func clearCurrentGrid()
}

extension EngineProtocol {
    init(rowCount: Int, colCount: Int) {
        self.init()
        rows = rowCount
        cols = colCount
    }
}
