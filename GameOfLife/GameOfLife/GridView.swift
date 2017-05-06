//
//  GridView.swift
//  Assignment4
//
//  Created by Benjamin Hendricks on 4/23/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//
import UIKit

protocol GridViewDelegate {
    func cellStateChanged(_ position: (Int, Int), newState: CellState)
}

enum GridViewOrigin {
    case instrumentation
    case simulation
}

class GridView: UIView {
    var delegate: GridViewDelegate?

    // change to instrumentation for GridEditor case. Default is simulation grid.
    var origin: GridViewOrigin = .simulation {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var size: Int {
        get {
            switch self.origin {
            case .simulation:
                return StandardEngine.engine.rows
            case .instrumentation:
                return self.grid.size.rows
            }
        }
        set {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var livingColor: UIColor = UIColor.green
    @IBInspectable var emptyColor: UIColor = UIColor.darkGray
    @IBInspectable var bornColor: UIColor = UIColor.green.withAlphaComponent(0.6)
    @IBInspectable var diedColor: UIColor = UIColor.darkGray.withAlphaComponent(0.6)
    @IBInspectable var gridColor: UIColor = UIColor.gray
    @IBInspectable var gridWidth: CGFloat {
        /**
        Inversely related:
         Changing from 10 to 40 rows, grid line width (2px @ 10 rows) is divided by [new row count] / [old row count]
         [new line width] = [ref line width] / ([new row count] / [ref row count])
         EX: ?? = 2 / (40 / 10) == 0.5 (new line width)
         */
        get {
            let engineRows = self.origin == .simulation ? StandardEngine.engine.rows : GridEditorEngine.engine.grid.size.rows
            return (Constants.Defaults.defaultGridLineWidth / (CGFloat(engineRows) / CGFloat(Constants.Defaults.defaultRowCount)))
        }
    }
    
    var grid: GridProtocol {
        get {
            switch origin {
            case .simulation:
                return StandardEngine.engine.grid
            case .instrumentation:
                return GridEditorEngine.engine.grid
            }

        }
        set {
            StandardEngine.engine.delegate?.engineDidUpdate(withGrid: self.grid, forceUpdate: false)
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func colorForCellState(_ cellState: CellState) -> UIColor {
        switch cellState {
        case .alive:
            return livingColor
        case .empty:
            return emptyColor
        case .born:
            return bornColor
        case .died:
            return diedColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        let gridSize: CGFloat = CGFloat(self.size)
        let cellSize = CGSize(
            width: rect.size.width / gridSize,
            height: rect.size.height / gridSize
        )
        
        (0 ..< self.size).forEach { i in
            (0 ..< self.size).forEach { j in
                let origin = CGPoint(
                    x: rect.origin.x + (CGFloat(j) * cellSize.width),
                    y: rect.origin.y + (CGFloat(i) * cellSize.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: cellSize
                )
                let currCellState = grid[(i,j)]
                let path = UIBezierPath(ovalIn: subRect)
                colorForCellState(currCellState).setFill()
                path.fill()
            }
        }
        
        //create the path
        (0 ..< self.size+1).forEach {
            let rectWidth = rect.size.width
            let rectHeight = rect.size.height
            let gridSize = CGFloat(self.size)
            let gridFactor = CGFloat($0)/gridSize
            drawLine(
                start: CGPoint(x: gridFactor * rectWidth, y: 0.0),
                end:   CGPoint(x: gridFactor * rectWidth, y: rectHeight)
            )
            
            drawLine(
                start: CGPoint(x: 0.0, y: gridFactor * rectHeight),
                end: CGPoint(x: rectWidth, y: gridFactor * rectHeight)
            )
        }
    }
    
    func drawLine(start:CGPoint, end: CGPoint) {
        let path = UIBezierPath()
        path.lineWidth = gridWidth
        path.move(to: start)
        path.addLine(to: end)
        gridColor.setStroke()
        path.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    typealias Position = (row: Int, col: Int)
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard let firstTouch = touches.first, touches.count == 1 else { return nil }

        let touchY = firstTouch.location(in: self.superview).y
        let touchX = firstTouch.location(in: self.superview).x
        guard touchX > frame.origin.x && touchX < (frame.origin.x + frame.size.width) else { return nil }
        guard touchY > frame.origin.y && touchY < (frame.origin.y + frame.size.height) else { return nil }

        let pos = convert(touch: firstTouch)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        delegate?.cellStateChanged(pos, newState: CellState.toggle(grid[(pos.row, pos.col)]))
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let touchLocation = touch.location(in: self)
        let gridHeight = frame.size.height
        let row = touchLocation.y / gridHeight * CGFloat(size)
        let gridWidth = frame.size.width
        let col = touchLocation.x / gridWidth * CGFloat(size)
        let position = (row: Int(row), col: Int(col))
        return position
    }
}
