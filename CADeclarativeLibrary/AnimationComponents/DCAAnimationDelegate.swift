//
//  DACAnimationDelegate.swift
//  CADeclarativeLibrary
//
//  Created by Dmitry on 13.06.2025.
//

import Foundation
import QuartzCore

final class DCAAnimationDelegate: NSObject, CAAnimationDelegate {
    
    var completion: (() -> ())?
    var didStart: (() -> ())?

    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) { completion?() }
    
    func animationDidStart(_ animation: CAAnimation) { didStart?() }
}
