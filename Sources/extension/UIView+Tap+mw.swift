//
//  UIView+Tap+mw.swift
//  Finger
//
//  Created by 陈晓东 on 2019/11/23.
//  Copyright © 2019 ccxdd. All rights reserved.
//

#if os(iOS)

import UIKit

private var ViewTapSupportKey: Void?
private let longTapTimeInterval = 1.0

private final class ViewTapSupport {
    var tapTime: TimeInterval = 0
    var touchUpInsideClosure: GenericsClosure<CGPoint>?
    var longUpInsideClosure: GenericsClosure<CGPoint>?
}

public extension UIView {
    private var vts: ViewTapSupport {
        guard let vts = objc_getAssociatedObject(self, &ViewTapSupportKey) as? ViewTapSupport else {
            let vts = ViewTapSupport()
            objc_setAssociatedObject(self, &ViewTapSupportKey, vts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return vts
        }
        return vts
    }
    
    func touchUpInside(_ handle: GenericsClosure<CGPoint>?) {
        isUserInteractionEnabled = true
        vts.touchUpInsideClosure = handle
    }
    
    func longUpInside(_ handle: GenericsClosure<CGPoint>?) {
        isUserInteractionEnabled = true
        vts.longUpInsideClosure = handle
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
        vts.tapTime = event?.timestamp ?? 0
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesEnded(touches, with: event)
        let r = vts.tapTime - (event?.timestamp ?? 0)
        guard let t = touches.first, frame.contains(t.location(in: self)) else { return }
        let p = t.location(in: self)
        if (r * -1) > longTapTimeInterval, vts.longUpInsideClosure != nil {
            vts.longUpInsideClosure?(p)
        } else {
            vts.touchUpInsideClosure?(p)
        }
    }
}

#endif
