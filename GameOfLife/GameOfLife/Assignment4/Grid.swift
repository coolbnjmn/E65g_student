//
//  Grid.swift
//
public typealias GridPosition = (row: Int, col: Int)
public typealias GridSize = (rows: Int, cols: Int)

fileprivate func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

public enum CellState: String {
    case alive, empty, born, died
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
    
    public func description() -> String {
        return self.rawValue
    }
    
    public func allValues() -> [CellState] {
        return [.alive, .born, .died, .empty]
    }
    
    static public func toggle(_ state: CellState) -> CellState {
        switch state {
        case .died, .empty:
            return .alive
        case .alive, .born:
            return .empty
        }
    }
}

public protocol GridProtocol {
    init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState)
    var description: String { get }
    var size: GridSize { get }
    subscript (row: Int, col: Int) -> CellState { get set }
    func mapOverGrid<T>(_ transform: (GridPosition, CellState) throws -> (GridPosition, T)) rethrows -> [[(GridPosition, T)]]
    func reduceOverGrid(_ size: Int, reducer: (Int, GridPosition) -> Int) -> Int
    func next() -> Self
}

public let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition($0) }
}


let offsets: [GridPosition] = [
    (row: -1, col:  -1), (row: -1, col:  0), (row: -1, col:  1),
    (row:  0, col:  -1),                     (row:  0, col:  1),
    (row:  1, col:  -1), (row:  1, col:  0), (row:  1, col:  1)
]

extension GridProtocol {
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Self {
        var nextGrid = Self(size.rows, size.cols) { _, _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
}

public struct Grid: GridProtocol {
    private var _cells: [[CellState]]
    public let size: GridSize

    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public func mapOverGrid<T>(_ transform: (GridPosition, CellState) throws -> (GridPosition, T)) rethrows -> [[(GridPosition, T)]] {
        return try _cells.map {
            cellRow in
            return try cellRow.map {
                cell in
                let rowIndex: Array.Index? = _cells.index(where: {
                    cellsRow in
                    let sameItems: [Bool] = cellsRow.map {
                        cellItem in
                        return (cellRow[cellsRow.index(of: cellItem) ?? 0] == cellItem)
                    }
                    return cellRow.count == cellsRow.count && sameItems.reduce(false, {
                        partialResult, nextItem in
                        return partialResult || nextItem
                    })
                })
                //                let row = _cells.index(of: cellRow)
                let colIndex: Array.Index? = cellRow.index(of: cell)
                guard let position: (Int, Int) = (rowIndex, colIndex) as? (Int, Int) else {
                    return try transform((0,0), cell)
                }
                
                return try transform(position, cell)
            }
        }
    }
    
    public func reduceOverGrid(_ size: Int, reducer: (Int, GridPosition) -> Int) -> Int {
        return (0 ..< size).reduce(0) { (total: Int, row: Int) -> Int in
            return (0 ..< size).reduce(total) { (subtotal, col) -> Int in
                return reducer(subtotal, (row, col))
            }
        }
    }

    public init(_ rows: Int, _ cols: Int, cellInitializer: (GridPosition) -> CellState = { _, _ in .empty }) {
        _cells = [[CellState]](repeatElement( [CellState](repeatElement(.empty, count: rows)), count: cols))
        size = GridSize(rows, cols)
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
}

extension Grid: Sequence {
    fileprivate var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col].isAlive   }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: GridProtocol
        private var history: GridHistory!
        
        public var living: [GridPosition] { return history.positions.filter { return  grid[$0, $1].isAlive   } }
        public var dead  : [GridPosition] {
            var positions = [GridPosition]()
            
            let deadCount = grid.reduceOverGrid(grid.size.rows, reducer: {
                subtotal, position in
                if !grid[(position.row, position.col)].isAlive {
                    positions.append(position)
                    return subtotal + 1
                } else {
                    return subtotal
                }
            })
            
            guard deadCount == positions.count else {
                // something went wrong??
                assertionFailure("Whoops, what went wrong here?")
                return []
            }
            return positions
        }
        public var alive : [GridPosition] { return history.positions.filter { return  grid[$0, $1] == .alive } }
        public var born  : [GridPosition] { return history.positions.filter { return  grid[$0, $1] == .born  } }
        public var died  : [GridPosition] { return history.positions.filter { return  grid[$0, $1] == .died  } }
        public var empty : [GridPosition] {
            var positions = [GridPosition]()
            
            let emptyCount = grid.reduceOverGrid(grid.size.rows, reducer: {
                subtotal, position in
                if grid[(position.row, position.col)] == .empty {
                    positions.append(position)
                    return subtotal + 1
                } else {
                    return subtotal
                }
            })
            
            guard emptyCount == positions.count else {
                // something went wrong??
                assertionFailure("Whoops, what went wrong here?")
                return []
            }
            return positions
        }

        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> GridProtocol? {
            if history.hasCycle { return nil }
            let newGrid:Grid = grid.next() as! Grid
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
        }
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case (0, 1), (1, 2), (2, 0), (2, 1), (2, 2): return .alive
        default: return .empty
        }
    }
}
