//
//  CallbackManager+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/8/7.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import Foundation

public typealias GenericsClosure<T> = (T) -> Void
public typealias GenericesReturnClosure<S, T> = (S) -> T
public typealias NoParamClosure = () -> Void

public enum CallbackCategory {
    case empty
    case optional
    case actual
    case leftNavBtn
    case rightNavBtn
    case tapGes
    case push
    case present
}

private var NSObjectCallbackManagerKey: Void?

public extension NSObject {
    var cbm: CallbackManager {
        let cbm: CallbackManager
        if let c = objc_getAssociatedObject(self, &NSObjectCallbackManagerKey) as? CallbackManager {
            cbm = c
        } else {
            cbm = CallbackManager()
            objc_setAssociatedObject(self, &NSObjectCallbackManagerKey, cbm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return cbm
    }
}

public final class CallbackManager {
    private var actual: Any?
    private var optional: Any?
    private var left: Any?
    private var right: Any?
    private var tapGes: Any?
    private var push: Any?
    private var present: Any?
    private var noParamClosure: NoParamClosure?
    var controlEventDict: [UInt: Any] = [:]
    
    public func empty(c: NoParamClosure?) {
        noParamClosure = c
    }
    
    public func actual<T>(t: T.Type, c: GenericsClosure<T>?) {
        actual = c
    }
    
    public func optional<T>(t: T.Type, c: GenericsClosure<T?>?) {
        optional = c
    }
    
    public func left<T>(t: T.Type, c: GenericsClosure<T>?) {
        left = c
    }
    
    public func right<T>(t: T.Type, c: GenericsClosure<T>?) {
        right = c
    }
    
    public func tap<T>(t: T.Type, c: GenericsClosure<T>?) {
        tapGes = c
    }
    
    public func push<T>(t: T.Type, c: GenericsClosure<T?>?) {
        push = c
    }
    
    public func present<T>(t: T.Type, c: GenericsClosure<T?>?) {
        present = c
    }
    
    public func exec<T>(c: CallbackCategory, p: T? = nil) {
        switch c {
        case .actual:
            (actual as? GenericsClosure)?(p!)
        case .optional:
            (optional as? GenericsClosure)?(p)
        case .empty:
            noParamClosure?()
        case .leftNavBtn:
            (left as? GenericsClosure)?(p!)
        case .rightNavBtn:
            (right as? GenericsClosure)?(p!)
        case .tapGes:
            (tapGes as? GenericsClosure)?(p!)
        case .push:
            (push as? GenericsClosure)?(p)
        case .present:
            (present as? GenericsClosure)?(p)
        }
    }
}

