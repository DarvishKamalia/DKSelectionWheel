//
//  DKSectionLayer.swift
//  animTest
//
//  Created by Darvish Kamalia on 1/7/16.
//  Copyright © 2016 Darvish Kamalia. All rights reserved.
//

import UIKit

class DKSectionLayer: CAShapeLayer {
    
    var highlightedPath: UIBezierPath! = nil
    var maximizedPath: UIBezierPath! = nil
    var minimizedPath: UIBezierPath! = nil
    let innerRadius: CGFloat = 50.0
    let outerRadius: CGFloat = 100.0
    let center: CGPoint
    var startAngle: CGFloat
    var endAngle: CGFloat
    
    init(startAngle: CGFloat, endAngle: CGFloat, center: CGPoint) {
        
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.center = center
        
        super.init()
        createMaximizedPath()
        createHighlightedPath()
        createMinimizedPath()

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: AnyObject) {
        self.startAngle = (layer as! DKSectionLayer).startAngle
        self.endAngle = (layer as! DKSectionLayer).endAngle
        self.center = (layer as! DKSectionLayer).center
        
        super.init(layer: layer)
    }
    
    /**
     Generates a tiny circle to use as the path for the layer to use in the minimized state
     - returns: The generated path
     */
    func createMinimizedPath(){
        
        minimizedPath = UIBezierPath()
        minimizedPath.addArcWithCenter(self.center, radius: 1, startAngle: 0, endAngle: CGFloat(2.0*M_PI), clockwise: true)
        
    }
    
    func createMaximizedPath(){
        
        maximizedPath = UIBezierPath()
        maximizedPath.addArcWithCenter(self.center, radius: innerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        maximizedPath.addArcWithCenter(self.center, radius: outerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        maximizedPath.closePath()
    }
    
    func createHighlightedPath() {
        
        highlightedPath = UIBezierPath()
        highlightedPath.addArcWithCenter(self.center, radius: innerRadius + 15, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        highlightedPath.addArcWithCenter(self.center, radius: outerRadius + 15, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        highlightedPath.closePath()
        
    }
}
