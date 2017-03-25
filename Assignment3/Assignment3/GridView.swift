//
//  GridView.swift
//  Assignment3
//
//  Created by Benjamin Hendricks on 3/25/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable
class GridView: UIView {

    @IBInspectable var size: Int = 20 {
        didSet {
            self.grid = Grid(size, size)
        }
    }

    @IBInspectable var livingColor: UIColor = UIColor.green
    @IBInspectable var emptyColor: UIColor = UIColor.darkGray
    @IBInspectable var bornColor: UIColor = UIColor.green.withAlphaComponent(0.6)
    @IBInspectable var diedColor: UIColor = UIColor.darkGray.withAlphaComponent(0.6)
    @IBInspectable var gridColor: UIColor = UIColor.gray
    @IBInspectable var gridWidth: CGFloat = 2.0

    var grid: Grid

    required init?(coder aDecoder: NSCoder) {
        self.grid = Grid(size, size)
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
        let pos = convert(touch: firstTouch)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        grid[(pos.row,pos.col)] = grid[(pos.row,pos.col)].toggle()
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
