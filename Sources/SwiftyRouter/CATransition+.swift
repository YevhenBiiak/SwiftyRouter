//
//  TransitionType.swift
//  SwiftyRouter
//
//  Created by Yevhen Biiak on 18.11.2024.
//

import UIKit


extension CATransition {
    public static func `default`(duration: CFTimeInterval = 0.25, type: TransitionType = .moveIn(.fromBottom)) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type.type
        transition.subtype = type.subtype
        return transition
    }
    public static func easeIn(duration: CFTimeInterval = 0.25, type: TransitionType = .moveIn(.fromBottom)) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type.type
        transition.subtype = type.subtype
        return transition
    }
    public static func easeInEaseOut(duration: CFTimeInterval = 0.25, type: TransitionType = .moveIn(.fromBottom)) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type.type
        transition.subtype = type.subtype
        return transition
    }
    public static func easeOut(duration: CFTimeInterval = 0.25, type: TransitionType = .moveIn(.fromBottom)) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type.type
        transition.subtype = type.subtype
        return transition
    }
    public static func linear(duration: CFTimeInterval = 0.25, type: TransitionType = .moveIn(.fromBottom)) -> CATransition {
        let transition = CATransition()
        transition.duration = duration
        transition.type = type.type
        transition.subtype = type.subtype
        return transition
    }
}


public struct TransitionType {
    fileprivate var type: CATransitionType
    fileprivate var subtype: CATransitionSubtype?
    
    public static let fade = TransitionType(type: .fade, subtype: nil)
    
    public static func fade(_ subtype: CATransitionSubtype) -> TransitionType {
        return TransitionType(type: .fade, subtype: subtype)
    }
    
    public static func moveIn(_ subtype: CATransitionSubtype) -> TransitionType {
        return TransitionType(type: .moveIn, subtype: subtype == .fromTop ? .fromBottom : subtype == .fromBottom ? .fromTop : subtype)
    }
    
    public static func push(_ subtype: CATransitionSubtype) -> TransitionType {
        return TransitionType(type: .push, subtype: subtype)
    }
    
    public static func reveal(_ subtype: CATransitionSubtype) -> TransitionType {
        return TransitionType(type: .reveal, subtype: subtype)
    }
}
