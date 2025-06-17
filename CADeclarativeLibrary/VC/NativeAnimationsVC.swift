//
//  NativeAnimationsVC.swift
//  CADeclarativeLibrary
//
//  Created by Dmitry on 02.06.2025.
//

import UIKit

final class NativeAnimationsVC: UIViewController {
    
    let animatedView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    let shapeLayer = CAShapeLayer()
    
    let keyframeLabel: UILabel = {
        let label = UILabel()
        label.text = "keyframeAnimation"
        label.textColor = .white
        return label
    }()
    
    let translationLabel: UILabel = {
        let label = UILabel()
        label.text = "translation"
        label.textColor = .white
        return label
    }()
    
    let keyframeLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.systemCyan.cgColor
        return layer
    }()
    
    let translationLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.systemCyan.cgColor
        return layer
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureButtonsStackView()
    }
    
    private func configureView() {
        view.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.widthAnchor.constraint(equalToConstant: 300),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 700),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureButtonsStackView() {
        var animationTypes = AnimationType.allCases
        for animationType in animationTypes {
            let button = UIButton()
            button.setTitle(animationType.rawValue, for: .normal)
            buttonsStackView.addArrangedSubview(button)
            button.backgroundColor = .lightGray
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(showAnimationController), for: .touchUpInside)
        }
    }
    
    @objc
    private func showAnimationController(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case AnimationType.keyframe.rawValue:
            navigationController?.pushViewController(DCAViewController(animationType: .keyframe), animated: true)
        case AnimationType.translation.rawValue:
            navigationController?.pushViewController(DCAViewController(animationType: .translation), animated: true)
        case AnimationType.rotation.rawValue:
            navigationController?.pushViewController(DCAViewController(animationType: .rotation), animated: true)
        case AnimationType.pathDeformation.rawValue:
            navigationController?.pushViewController(DCAViewController(animationType: .pathDeformation), animated: true)
        case AnimationType.shear.rawValue:
            navigationController?.pushViewController(DCAViewController(animationType: .shear), animated: true)
        default:
            print("not matched keys")
        }
    }
        
        
        func startRotationAnimation(layer: CALayer) {
            let keyPath = "transform.rotation.y"
            let rotationAnimation = CABasicAnimation(keyPath: keyPath)
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi
            rotationAnimation.duration = 2.0
            rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            rotationAnimation.repeatCount = 1
            layer.removeAnimation(forKey: keyPath)
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500.0
            layer.transform = transform
            layer.add(rotationAnimation, forKey: keyPath)
        }
        
        func startTranslationAnimation(layer: CALayer) {
            let animation = CABasicAnimation(keyPath: "transform.translation")
            animation.toValue = NSValue(cgPoint: CGPoint(x: 100, y: 50))
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            layer.add(animation, forKey: "translation")
        }
        
        func startScaleAnimation() {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = 1.5
            animation.duration = 2.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animatedView.layer.add(animation, forKey: "scale")
        }
        
        func startRotationAnimation() {
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500.0
            
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: transform)
            transform = CATransform3DRotate(transform, .pi, 0, 1, 0)
            animation.toValue = NSValue(caTransform3D: transform)
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = 1.5
            animatedView.layer.add(animation, forKey: "rotation")
        }
        
        func startPerspectiveAnimation() {
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500.0
            
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: transform)
            transform = CATransform3DRotate(transform, .pi / 2, 0, 1, 0)
            animation.toValue = NSValue(caTransform3D: transform)
            animation.duration = 2.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animatedView.layer.add(animation, forKey: "perspective")
        }
        
        func startShearAnimation() {
            var transform = CATransform3DIdentity
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: transform)
            transform.m12 = 0.5
            transform.m21 = 0.5
            animation.toValue = NSValue(caTransform3D: transform)
            animation.duration = 2.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animatedView.layer.add(animation, forKey: "shear")
        }
        
        func startProjectionAnimation() {
            var transform = CATransform3DIdentity
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: transform)
            transform.m14 = 0.002
            transform.m24 = 0.002
            animation.toValue = NSValue(caTransform3D: transform)
            animation.duration = 2.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animatedView.layer.add(animation, forKey: "projection")
        }
        
        func startDeformationAnimation() {
            let startPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100)).cgPath
            let endPath = CGMutablePath()
            endPath.move(to: CGPoint(x: 0, y: 0))
            endPath.addLine(to: CGPoint(x: 100, y: 0))
            endPath.addQuadCurve(
                to: CGPoint(x: 100, y: 100),
                control: CGPoint(x: 150, y: 50)
            )
            endPath.addLine(to: CGPoint(x: 0, y: 100))
            endPath.closeSubpath()
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = startPath
            animation.toValue = endPath
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            
            shapeLayer.add(animation, forKey: "deformation")
        }
        
        func startKeyframeAnimation(layer: CALayer) {
            let keyframeAnimation = CAKeyframeAnimation(keyPath: "position")
            keyframeAnimation.values = [
                CGPoint(x: 80, y: 150),
                CGPoint(x: 120, y: 150),
                CGPoint(x: 120, y: 190),
                CGPoint(x: 80, y: 190),
                CGPoint(x: 80, y: 150)
            ]
            keyframeAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            keyframeAnimation.duration = 1
            keyframeAnimation.repeatCount = 20
            keyframeAnimation.fillMode = .forwards
            keyframeAnimation.autoreverses = true
            layer.add(keyframeAnimation, forKey: "keyframeAnimation")
        }
}
