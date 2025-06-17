//
//  AnimationBuilder.swift
//  CADeclarativeLibrary
//
//  Created by Dmitry on 31.05.2025.
//

import UIKit

final class DCAAnimationBuilder {
    
    enum DeformationType {
        case ovalIN
        case rect(cornerRadius: CGFloat?)
        case arcCenter(angle: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
        case triangle
        case star
        case heart
        case arrow
        case blob
    }
    
    enum AxisType: String {
        case x = "x"
        case y = "y"
        case z = "z"
    }
    
    private var animations: [CAAnimation] = []
    private let animationGroupDelegate = DCAAnimationDelegate()
    private var animatableLayer: CALayer = CALayer()
    private var timingFunction: CAMediaTimingFunction? = nil
    private var completion: (() -> ())?
    
    init(){}
    
    init(for layer: CALayer) { self.animatableLayer = layer }
    
    @discardableResult
    func rotation(
        angleDegree: CGFloat = 0,
        angleRadians: CGFloat = 0,
        superLayer: CALayer? = nil,
        axis: AxisType,
        perspective: CGFloat = -1.0 / 500.0,
        duration: Double = 1,
        repeatCount: Float = 1,
        timingFunctionName: CAMediaTimingFunctionName = .linear,
        autoreverses: Bool = false
    ) -> DCAAnimationBuilder {
        let keyPath = "transform.rotation.\(axis.rawValue)"
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = 0
        animation.toValue = angleDegree == 0 ? angleRadians : angleDegree * .pi / 180
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animations.append(animation)
        return self
    }
    
    @discardableResult
    func translation(
        toValueX: Int,
        toValueY: Int,
        keyPath: String = "transform.translation",
        duration: Double = 1,
        repeatCount: Float = 1,
        autoreverses: Bool = false)
    -> DCAAnimationBuilder {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = CGPoint(x: toValueX, y: toValueY)
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        animations.append(animation)
        return self
    }
    
    @discardableResult
    func scale(
        toValue: CGFloat,
        duration: Double = 1,
        timingFunctionName: CAMediaTimingFunctionName = .linear,
        repeatCount: Float = 1,
        autoreverses: Bool = false,
        keyPath: String = "transform.scale"
    ) -> DCAAnimationBuilder {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = toValue
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        animations.append(animation)
        return self
    }
    
    @discardableResult
    func perspective(superLayer: CALayer, m34: CGFloat) -> Self {
        superLayer.sublayerTransform.m34 = m34
        return self
    }
    
    @discardableResult
    func withCompletion(_ completion: @escaping () -> ()) -> Self {
        self.animationGroupDelegate.completion = completion
        return self
    }
    
    @discardableResult
    func withStartFunction(_ startFunction: @escaping () -> ()) -> Self {
        self.animationGroupDelegate.didStart = startFunction
        return self
    }
    
    @discardableResult
    func shear(
        x: CGFloat,
        y: CGFloat,
        keyPath: String = "transform",
        animationKey: String = "shearAnimation",
        duration: Double,
        autoreverses: Bool = false,
        repeatCount: Float = 1
    ) -> DCAAnimationBuilder {
        let animation = CABasicAnimation(keyPath: keyPath)
        var transform = CATransform3DIdentity
        animation.fromValue = CATransform3DIdentity
        transform.m21 = x
        transform.m12 = y
        animation.toValue = transform
        animation.duration = duration
        animation.autoreverses = autoreverses
        animation.repeatCount = repeatCount
        animations.append(animation)
        return self
    }
    
    @discardableResult
    func pathDeformation(
        for layer: CAShapeLayer,
        to endPathType: DeformationType? = nil,
        customEndPath: CGPath? = nil,
        duration: Double
    ) -> DCAAnimationBuilder {
        let startPath = layer.path
        
        let endPath = endPathType == nil ? customEndPath : endPathFactory(type: endPathType ?? .ovalIN, bounds: layer.bounds, center: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY))
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startPath
        animation.toValue = endPath
        animation.duration = duration
        animations.append(animation)
        return self
    }
    
    private func endPathFactory(
        type: DeformationType,
        bounds: CGRect,
        center: CGPoint
    ) -> CGPath {
        switch type {
        case .ovalIN:
            return CGPath(ellipseIn: bounds, transform: nil)
            
        case .rect(let cornerRadius):
            let radius = cornerRadius ?? 0
            return CGPath(roundedRect: bounds, cornerWidth: radius, cornerHeight: radius, transform: nil)
            
        case .arcCenter(let angle, let radius, let startAngle, let endAngle, let clockwise):
            let path = CGMutablePath()
            path.addArc(center: angle, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            return path
            
        case .triangle:
            let path = CGMutablePath()
            let top = CGPoint(x: bounds.midX, y: bounds.minY)
            let bottomLeft = CGPoint(x: bounds.minX, y: bounds.maxY)
            let bottomRight = CGPoint(x: bounds.maxX, y: bounds.maxY)
            path.move(to: top)
            path.addLine(to: bottomLeft)
            path.addLine(to: bottomRight)
            path.closeSubpath()
            return path
            
        case .star:
            let path = CGMutablePath()
            let outerRadius = min(bounds.width, bounds.height) / 2
            let innerRadius = outerRadius * 0.4
            let points = 5
            for i in 0..<points * 2 {
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let angle = CGFloat(i) * .pi / CGFloat(points)
                let point = CGPoint(
                    x: center.x + radius * cos(angle),
                    y: center.y + radius * sin(angle)
                )
                i == 0 ? path.move(to: point) : path.addLine(to: point)
            }
            path.closeSubpath()
            return path
            
        case .heart:
            let path = CGMutablePath()
            let width = bounds.width
            let height = bounds.height
            let x = bounds.minX
            let y = bounds.minY
            path.move(to: CGPoint(x: x + width / 2, y: y + height))
            path.addQuadCurve(
                to: CGPoint(x: x, y: y + height / 4),
                control: CGPoint(x: x + width / 4, y: y + height / 2)
            )
            path.addArc(
                center: CGPoint(x: x + width / 4, y: y + height / 4),
                radius: width / 4,
                startAngle: .pi,
                endAngle: 0,
                clockwise: false
            )
            path.addArc(
                center: CGPoint(x: x + 3 * width / 4, y: y + height / 4),
                radius: width / 4,
                startAngle: .pi,
                endAngle: 0,
                clockwise: false
            )
            path.addQuadCurve(
                to: CGPoint(x: x + width / 2, y: y + height),
                control: CGPoint(x: x + 3 * width / 4, y: y + height / 2)
            )
            return path
            
        case .arrow:
            let path = CGMutablePath()
            let width = bounds.width
            let height = bounds.height
            let x = bounds.minX
            let y = bounds.minY
            path.move(to: CGPoint(x: x + width / 2, y: y))
            path.addLine(to: CGPoint(x: x + width, y: y + height / 2))
            path.addLine(to: CGPoint(x: x + 3 * width / 4, y: y + height / 2))
            path.addLine(to: CGPoint(x: x + 3 * width / 4, y: y + height))
            path.addLine(to: CGPoint(x: x + width / 4, y: y + height))
            path.addLine(to: CGPoint(x: x + width / 4, y: y + height / 2))
            path.addLine(to: CGPoint(x: x, y: y + height / 2))
            path.closeSubpath()
            return path
            
        case .blob:
            let path = CGMutablePath()
            let points = 8
            let radius = min(bounds.width, bounds.height) / 2
            let variation = radius * 0.2
            for i in 0..<points {
                let angle = CGFloat(i) * 2 * .pi / CGFloat(points)
                let randomVariation = CGFloat.random(in: -variation...variation)
                let point = CGPoint(
                    x: center.x + (radius + randomVariation) * cos(angle),
                    y: center.y + (radius + randomVariation) * sin(angle)
                )
                if i == 0 {
                    path.move(to: point)
                } else {
                    let prevAngle = CGFloat(i - 1) * 2 * .pi / CGFloat(points)
                    let prevPoint = CGPoint(
                        x: center.x + (radius + CGFloat.random(in: -variation...variation)) * cos(prevAngle),
                        y: center.y + (radius + CGFloat.random(in: -variation...variation)) * sin(prevAngle)
                    )
                    let control = CGPoint(
                        x: (prevPoint.x + point.x) / 2,
                        y: (prevPoint.y + point.y) / 2
                    )
                    path.addQuadCurve(to: point, control: control)
                }
            }
            path.closeSubpath()
            return path
        }
    }
    
    func keyframeAnimate(
        values: [(x:Int, y:Int)],
        keyTimes: [NSNumber] = [],
        duration: Double = 1,
        fillMode: CAMediaTimingFillMode = .forwards,
        repeatCount: Float = 1,
        keyPath: String = "position",
        isRemovedOnCompletion: Bool = false,
        autoreverses: Bool = false
    ) -> Self {
        let keyframeAnimation = CAKeyframeAnimation(keyPath: keyPath)
        keyframeAnimation.values = values.map { CGPoint(x: $0.x, y: $0.y) }
        keyframeAnimation.keyTimes = keyTimes
        keyframeAnimation.duration = duration
        keyframeAnimation.fillMode = fillMode
        keyframeAnimation.isRemovedOnCompletion = isRemovedOnCompletion
        keyframeAnimation.repeatCount = repeatCount
        keyframeAnimation.autoreverses = autoreverses
        animations.append(keyframeAnimation)
        return self
    }
    
    func withLinearTimingFunction() -> Self {
        timingFunction = CAMediaTimingFunction(name: .linear)
        return self
    }
    
    func withEaseInEaseOutTimingFunction() -> Self {
        timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return self
    }
    
    func withEaseOutTimingFunction() -> Self {
        timingFunction = CAMediaTimingFunction(name: .easeOut)
        return self
    }
    
    func withEaseInTimingFunction() -> Self {
        timingFunction = CAMediaTimingFunction(name: .easeIn)
        return self
    }
    
    func withDefaultTimingFunction() -> Self {
        timingFunction = CAMediaTimingFunction(name: .default)
        return self
    }
    
    func withCustomTimingFunction(
        controlPoints: (x1: Float, y1: Float, x2: Float, y2: Float)
    ) -> Self {
        timingFunction = CAMediaTimingFunction(
            controlPoints: 
                controlPoints.x1,
                controlPoints.y1,
                controlPoints.x2,
                controlPoints.y2
            )
        return self
    }
    
    func apply(
        to layer: CALayer,
        duration: Double,
        repeatCount: Float = 1,
        autoreverses: Bool = false
    ) {
        animatableLayer = layer
        let group = CAAnimationGroup()
        group.animations = animations
        group.repeatCount = Float(repeatCount)
        group.autoreverses = autoreverses
        group.duration = duration
        group.timingFunction = timingFunction
        group.delegate = animationGroupDelegate
        DispatchQueue.main.async {
            layer.add(group, forKey: "animationGroup")
        }
    }
    
    func apply(
        duration: Double,
        repeatCount: Float = 1,
        autoreverses: Bool = false
    ) {
        let group = CAAnimationGroup()
        group.animations = animations
        group.repeatCount = Float(repeatCount)
        group.autoreverses = autoreverses
        group.duration = duration
        group.timingFunction = timingFunction
        group.delegate = animationGroupDelegate
        DispatchQueue.main.async {
            self.animatableLayer.add(group, forKey: "animationGroup")
        }
    }
    
    func apply(duration: Double, shapeLayer: CAShapeLayer) {
        let group = CAAnimationGroup()
        group.animations = animations
        group.delegate = animationGroupDelegate
        group.duration = duration
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        DispatchQueue.main.async {
            shapeLayer.add(group, forKey: "animationGroup")
        }
    }
}
