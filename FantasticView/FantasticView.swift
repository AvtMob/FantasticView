//
//  FantasticView.swift
//  FantasticView
//
//  Created by Avtar Singh on 3/7/18.
//  Copyright © 2018 HBdevelopers. All rights reserved.
//

import Foundation
import UIKit

enum FantasticViewMode:String{
    case square,circle,ovel,triangle,star
    //     0       1    2   3       4       5
}

class FantasticView : UIView {
   
    let colors : [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple,.brown,.black,.cyan,.magenta,.darkGray]
    var colorCounter = 0
    
    @IBInspectable var stroke : CGFloat = 1.0{
        didSet{
            drawShape()
        }
    }
    
    @IBInspectable var strokeColor: UIColor = UIColor.clear{
        didSet{
            shapeLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    
    @IBInspectable var fillColor: UIColor = UIColor.gray{
        didSet{
            shapeLayer.fillColor = fillColor.cgColor
        }
    }
    
    
    @IBInspectable var mode : String = FantasticViewMode.square.rawValue{
        didSet{
            drawShape()
        }
    }
    
    @IBInspectable var animateStrokeColor : Bool = true{
        didSet{
            toggleColorAnimation()
        }
    }
    
    @IBInspectable var animateStrokeColorTimeInterval : CGFloat = 1.0
    
    private let shapeLayer = CAShapeLayer()
    
    private var colorTimer : Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // The Main Stuff
        drawShape()
        toggleColorAnimation()
        print("Frame Init")
    }
    
    override func awakeFromNib() {
        drawShape()
        toggleColorAnimation()
        print("awakeFromNib")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // You don't need to implement this
    }
    
    private func drawShape(){
        self.layer.sublayers?.removeAll()
        switch mode{
        case FantasticViewMode.square.rawValue: 
            self.drawSquare(rect: self.bounds, stroke: self.stroke,strokeColor: self.strokeColor.cgColor,fillColor: self.fillColor.cgColor)
            break
        case FantasticViewMode.circle.rawValue:
            drawCirlce()
            break
        case FantasticViewMode.ovel.rawValue: 
            drawOvel()
            break
        case FantasticViewMode.triangle.rawValue: 
            drawTriangle()
            break
            
        case FantasticViewMode.star.rawValue:
            drawStar(rect: self.bounds)
            break
            
        default:
            break
        }
    }
    
    func toggleColorAnimation(){
        if animateStrokeColor{
            colorTimer = Timer.scheduledTimer(withTimeInterval: self.animateStrokeColorTimeInterval, repeats: true) { (timer) in  //1
                UIView.animate(withDuration: self.animateStrokeColorTimeInterval) {  //2
                    self.shapeLayer.strokeColor = self.colors[self.colorCounter].cgColor  //3
                    self.colorCounter = Int.random(in: 0 ..< self.colors.count)  //4
                }
            }
            colorTimer?.fire()  //5
        }else{
            colorTimer?.invalidate()
            colorTimer = nil
        }
    }
    
    func drawTriangle(){
        shapeLayer.frame = self.bounds
        shapeLayer.lineWidth = stroke
        shapeLayer.fillColor = fillColor.cgColor
        let path = UIBezierPath()
        let xAxis = self.bounds.origin.x
        let yAxis = self.bounds.origin.y
        let width = self.bounds.width
        let height = self.bounds.height
        path.move(to: CGPoint(x: xAxis + (width * 0.5), y: yAxis + 0))
        path.addLine(to: CGPoint(x: xAxis + width, y: yAxis + height))
        path.addLine(to: CGPoint(x: xAxis + 0, y: yAxis + height))
        path.addLine(to: CGPoint(x: xAxis + width * 0.5, y: yAxis + 0))
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
        
    }
    
    internal func drawOvel() {
        let circlePath = UIBezierPath(ovalIn: CGRectInset(self.bounds,stroke/2,stroke/2))
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = stroke
        layer.addSublayer(shapeLayer)
    }
    
    internal func drawSquare(rect: CGRect,stroke:CGFloat,strokeColor:CGColor? = nil,fillColor:CGColor? = nil){
        shapeLayer.frame = rect
        shapeLayer.lineWidth = stroke
        shapeLayer.strokeColor = strokeColor
        shapeLayer.fillColor = fillColor
        shapeLayer.path = UIBezierPath(rect: shapeLayer.bounds).cgPath
        layer.addSublayer(shapeLayer)
    }
    
    func drawCirlce(){
        shapeLayer.frame = self.bounds
        shapeLayer.lineWidth = stroke
        shapeLayer.fillColor = fillColor.cgColor

        let arcCenter = shapeLayer.position
        let radius = shapeLayer.bounds.size.width / 2.0
        let startAngle = CGFloat(0.0)
        let endAngle = CGFloat(2.0 * .pi)
        let clockwise = true

        let circlePath = UIBezierPath(arcCenter: arcCenter,
                                         radius: radius,
                                     startAngle: startAngle,
                                       endAngle: endAngle,
                                      clockwise: clockwise)

        shapeLayer.path = circlePath.cgPath
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawStar(rect:CGRect){
       
        shapeLayer.frame = rect
        shapeLayer.lineWidth = 2.0
        shapeLayer.strokeColor = self.strokeColor.cgColor
        shapeLayer.fillColor = self.fillColor.cgColor

        let starPath = UIBezierPath()
        let center = shapeLayer.position

        let numberOfPoints = CGFloat(5.0)
        let numberOfLineSegments = Int(numberOfPoints * 2.0)
        let theta = .pi / numberOfPoints

        let circumscribedRadius = center.x
        let outerRadius = circumscribedRadius * 1.039
        let excessRadius = outerRadius - circumscribedRadius
        let innerRadius = CGFloat(outerRadius * 0.382)

        let leftEdgePointX = (center.x + cos(4.0 * theta) * outerRadius) + excessRadius
        let horizontalOffset = leftEdgePointX / 2.0

        // Apply a slight horizontal offset so the star appears to be more
        // centered visually
        let offsetCenter = CGPoint(x: center.x - horizontalOffset, y: center.y)

        // Alternate between the outer and inner radii while moving evenly along the
        // circumference of the circle, connecting each point with a line segment
        for i in 0..<numberOfLineSegments {
            let radius = i % 2 == 0 ? outerRadius : innerRadius

            let pointX = offsetCenter.x + cos(CGFloat(i) * theta) * radius
            let pointY = offsetCenter.y + sin(CGFloat(i) * theta) * radius
            let point = CGPoint(x: pointX, y: pointY)

            if i == 0 {
                starPath.move(to: point)
            } else {
                starPath.addLine(to: point)
            }
        }

        starPath.close()

        // Rotate the path so the star points up as expected
        var pathTransform  = CGAffineTransform.identity
        pathTransform = pathTransform.translatedBy(x: center.x, y: center.y)
        pathTransform = pathTransform.rotated(by: CGFloat(-.pi / 2.0))
        pathTransform = pathTransform.translatedBy(x: -center.x, y: -center.y)

        starPath.apply(pathTransform)

        shapeLayer.path = starPath.cgPath
        layer.addSublayer(shapeLayer)
    }
}
