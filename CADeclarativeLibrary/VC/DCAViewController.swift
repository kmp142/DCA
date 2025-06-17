//
//  DACViewController.swift
//  CADeclarativeLibrary
//
//  Created by Dmitry on 02.06.2025.
//

import UIKit

enum AnimationType: String, CaseIterable {
    case keyframe = "keyframe"
    case translation = "translation"
    case rotation = "rotation"
    case pathDeformation = "pathDeformation"
    case shear = "shear"
}

final class DCAViewController: UIViewController {
    
    let animatedView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let animatedLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.systemCyan.cgColor
        return layer
    }()
    
    let shapeLayer = CAShapeLayer()
    
    private let animationType: AnimationType
    
    init(animationType: AnimationType) {
        self.animationType = animationType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if animationType == .pathDeformation {
            animatedLayer.removeFromSuperlayer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch animationType {
        case .keyframe:
            startKeyframeAnimation()
        case .translation:
            startTranslationAnimation()
        case .rotation:
            startRotationAnimation()
        case .pathDeformation:
            configureCAShapeLayer()
            startPathDeformationAnimation()
        case .shear:
            startShearAnimation()
        }
    }
    
    private func configureView() {
        animatedLayer.frame.size = CGSize(width: 200, height: 200)
        animatedLayer.position = view.layer.position
        animatedLayer.backgroundColor = UIColor.systemPink.cgColor
        view.layer.addSublayer(animatedLayer)
        view.backgroundColor = .black
    }
    
    private func configureCAShapeLayer() {
        shapeLayer.fillColor = UIColor.cyan.cgColor
        shapeLayer.frame.size = CGSize(width: 150, height: 150)
        shapeLayer.position = view.layer.position
        shapeLayer.path = CGPath(rect: CGRect(x: 0, y: 0, width: 150, height: 150), transform: nil)
        view.layer.addSublayer(shapeLayer)
    }
    
    private func startKeyframeAnimation() {
        DCAAnimationBuilder()
            .keyframeAnimate(
                values: [
                (x: 200, y: 200),
                (x: 330, y: 500),
                (x: 200, y: 800)
                ],
                keyTimes: [0.0, 0.50, 1.0],
                repeatCount: .infinity,
                autoreverses: true
            )
            .withCompletion { print("keyframe animation ended") }
            .withStartFunction { print("keyframe animation did start") }
            .apply(to: animatedLayer, duration: 100)
    }
    
    private func startTranslationAnimation() {
        DCAAnimationBuilder()
            .translation(
                toValueX: 50,
                toValueY: 200,
                duration: 3,
                repeatCount: .infinity,
                autoreverses: true
            )
            .withCompletion { print("translation animation ended") }
            .withStartFunction { print("translation animation did start") }
            .apply(
                to: animatedLayer,
                duration: 2
            )
    }
    
    private func startRotationAnimation() {
        DCAAnimationBuilder()
            .perspective(superLayer: animatedLayer.superlayer ?? CALayer(), m34: -1 / 300)
            .rotation(
                angleDegree: 720,
                superLayer: animatedLayer.superlayer,
                axis: .y,
                duration: 5,
                repeatCount: 10,
                timingFunctionName: .linear,
                autoreverses: true
            )
            .withStartFunction { print("rotation animation started") }
            .withCompletion { print("rotation animation ended") }
            .apply(to: animatedLayer, duration: 5)
    }
    
    private func startShearAnimation() {
        DCAAnimationBuilder()
            .shear(
                x: 0.2,
                y: 0.5,
                duration: 2,
                autoreverses: true,
                repeatCount: 2
            )
            .withStartFunction { print("shear animation started") }
            .withCompletion { print("shear animation ended") }
            .apply(to: animatedLayer, duration: 4)
    }
    
    private func startPathDeformationAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
        DCAAnimationBuilder()
            .pathDeformation(
                for: self.shapeLayer,
                to: .arrow,
                duration: 0.5
            )
            .withStartFunction { print("path deformation animation started") }
            .withCompletion { print("path deformation animation ended") }
            .apply(duration: 0.5, shapeLayer: self.shapeLayer)
        })
    }
}
