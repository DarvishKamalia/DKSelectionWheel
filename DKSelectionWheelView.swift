//
//  DKSelectionWheelView.swift
//  animTest
//
//  Created by Darvish Kamalia on 1/7/16.
//  Copyright © 2016 Darvish Kamalia. All rights reserved.
//

import UIKit

enum MenuState {
    case Open
    case Closed
}

class DKSelectionWheelView: UIView, UIGestureRecognizerDelegate {

    let numSections = 5
    
    let separationAngle: CGFloat = CGFloat(10.0 * (M_PI/180.0))
    let animationDuration = 0.1
    var state: MenuState? = nil
    var menuOrigin: CGPoint? = nil
    var selectedLayer: DKSectionLayer! = nil
    let highlightColor = UIColor(red: 0.2902, green: 0.898, blue: 0.9098, alpha: 1.0)
    
    var sections: [DKSectionLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "userDidLongPress:")
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "userDidPan:")
        longPressRecognizer.delegate = self
        panRecognizer.delegate = self
        
        self.addGestureRecognizer(longPressRecognizer)
        self.addGestureRecognizer(panRecognizer)
        
        state = .Closed //Initially the menu is closed
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    
    Creates the menu around a given origin point
    - parameter center
    
    */
    func createPathsWithCenter(center: CGPoint)  {
        
        self.menuOrigin = center
        
        let totalAvailableBaseAngle = CGFloat(M_PI) - (separationAngle * CGFloat((numSections - 1))) //Compute how much angle is available for drawing
        let anglePerSection:CGFloat = totalAvailableBaseAngle/CGFloat(numSections)
        var currentStartAngle: CGFloat = CGFloat(M_PI)
        var currentEndAngle:CGFloat = currentStartAngle + anglePerSection
        
        for i in 1...numSections {
            
            //Animate the path
            let layer = DKSectionLayer(startAngle: currentStartAngle, endAngle: currentEndAngle, center: self.menuOrigin!)
            layer.strokeColor = self.highlightColor.CGColor
            layer.fillColor = UIColor.clearColor().CGColor
            layer.path = layer.minimizedPath.CGPath
            let anim = CABasicAnimation(keyPath: "path")
            anim.fromValue = layer.path
            layer.path = layer.maximizedPath.CGPath
            anim.toValue = layer.path
            anim.duration = animationDuration * Double(i)
            layer.addAnimation(anim, forKey: "animPath")
            sections.append(layer)
            
            self.layer.addSublayer(layer)
            
            currentStartAngle += anglePerSection + separationAngle
            currentEndAngle = currentStartAngle + anglePerSection
            
            
        }
        
        
    }
    
//    func findCenterForSection(section: Int) -> CGPoint{
//        
//        let totalAvailableBaseAngle = CGFloat(M_PI) - (separationAngle * CGFloat((numSections - 1))) //Compute how much angle is available for drawing
//        let anglePerSection:CGFloat = CGFloat(M_PI)/CGFloat(numSections)
//        
//        let centerPointAngle = anglePerSection/2 + CGFloat(section - 1)*anglePerSection
//        
//        print(centerPointAngle * 57.3)
//        let radiusDifference = (outerRadius - innerRadius)/2 + innerRadius
//        let xPos = self.menuOrigin!.x + cos(centerPointAngle)*radiusDifference
//        let yPos = (self.menuOrigin?.y)! - sin(centerPointAngle)*radiusDifference
//        
//        print (" \(self.menuOrigin!.x) \(xPos) ")
//        return CGPoint(x: xPos, y: yPos)
//    }
    
    func degreesToRadians (degreeValue: CGFloat) ->CGFloat {
        return degreeValue * CGFloat((M_PI/180.0))
    }
    
    func userDidLongPress(gestureRecognizer: UIGestureRecognizer) {
        if (self.state == .Closed) {
            createPathsWithCenter(gestureRecognizer.locationInView(self))
            self.state = .Open
        }
    }
    
    func userDidPan (gestureRecognizer: UIGestureRecognizer) {
        if (self.state == .Closed) {
            return
        }
        
        if (gestureRecognizer.state == .Changed) {
            
            let currentPanPosition = gestureRecognizer.locationInView(self)
            let panAngle = computePanAngle(currentPanPosition)
            let anglePerSection = M_PI/Double(numSections)
            let currentSection = Int(floor(panAngle/anglePerSection))
            
            if (currentSection >= 0 && currentSection < sections.count) {
                
                let newLayer = sections[sections.count - currentSection - 1]
                
                guard newLayer != selectedLayer else {
                    return //Perform animations only if the selected layer has changed
                }
                
                restoreAllSectionsToNormalState()
                selectedLayer = newLayer
                selectedLayer.shadowColor = UIColor.blackColor().CGColor
                selectedLayer.shadowOffset = CGSize(width: 0, height: 8)
                
                //Prepare individual animations
                let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
                shadowRadiusAnimation.fromValue = 0.0
                selectedLayer.shadowRadius = 2
                shadowRadiusAnimation.toValue = selectedLayer.shadowRadius
                
                let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
                selectedLayer.shadowOpacity = 0.3
                shadowOpacityAnimation.toValue = selectedLayer.shadowOpacity
                
                let fillColorAnimation = CABasicAnimation(keyPath: "fillColor")
                selectedLayer.fillColor = self.highlightColor.CGColor
                fillColorAnimation.toValue = selectedLayer.fillColor
                
                let pathAnimation = CABasicAnimation(keyPath: "path")
                pathAnimation.fromValue = selectedLayer.path
                selectedLayer.path = selectedLayer.highlightedPath.CGPath
                pathAnimation.toValue = selectedLayer.path
                
                //Group the animations for shadow and color
                let animationGroup = CAAnimationGroup()
                animationGroup.duration = 0.2
                animationGroup.animations = [fillColorAnimation, pathAnimation]
                selectedLayer.addAnimation(animationGroup, forKey: "HighlightAnimation")
                
            }
                
            else {
                restoreAllSectionsToNormalState()
                selectedLayer = nil
            }
            
        }
            
        else if (gestureRecognizer.state == .Ended) {
            for section in sections {
                
                if (section != selectedLayer) {
                    
                    let minimizeAnimation = CABasicAnimation(keyPath: "path")
                    minimizeAnimation.fromValue = section.path
                    section.path = section.minimizedPath.CGPath
                    minimizeAnimation.toValue = section.path
                    minimizeAnimation.duration = 0.1
                    section.addAnimation(minimizeAnimation, forKey: "minimize")
                    
                }
                    
                else {
                    
                    let pulseAnimation = CABasicAnimation(keyPath: "fillColor")
                    pulseAnimation.toValue = UIColor.clearColor().CGColor
                    pulseAnimation.autoreverses = true
                    pulseAnimation.repeatCount = 2
                    pulseAnimation.removedOnCompletion = false
                    pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    pulseAnimation.duration = 0.1
                    pulseAnimation.delegate = self
                    section.addAnimation(pulseAnimation, forKey: "SelectedLayerPulse")
                    
                }
                
            }
        }
        
    }
    
    /**
     Returns all menu sections to their normal, non-highlighted, *maximized* state
     */
    func restoreAllSectionsToNormalState() {
        for section in self.sections {
            section.fillColor = UIColor.clearColor().CGColor
            section.shadowRadius = 0.0
            section.shadowOpacity = 0.0
            section.shadowColor = UIColor.clearColor().CGColor
            section.path = section.maximizedPath.CGPath
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /**
     Determines the angle of the pan gesture WRT to the center of the menu, to help determine what section is currently selected
     - parameter panPosition The point the user has currently panned to
     - returns: The computed angle
     */
    func computePanAngle (panPosition : CGPoint) -> Double {
        
        let origin = self.menuOrigin!
        let xDisplacement = panPosition.x - origin.x
        let yDisplacement = origin.y - panPosition.y
        
        var angle = Double(atan(yDisplacement/xDisplacement))
        
        if (xDisplacement < 0) {
            angle += M_PI
        }
        
        return angle
    }
    
    /**
     Called when the pulse animation finishes
     */
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        let minimizeAnimation = CABasicAnimation(keyPath: "path")
        minimizeAnimation.fromValue = self.selectedLayer.path
        self.selectedLayer.path = selectedLayer.minimizedPath.CGPath
        minimizeAnimation.toValue = self.selectedLayer.path
        minimizeAnimation.duration = 0.1
        self.selectedLayer.addAnimation(minimizeAnimation, forKey: "minimize")
        
    }
    


}
