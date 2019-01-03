//
//  UIView+NSLayoutConstraint+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 16/6/18.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

public enum LayoutDimension {
    case width, height, none
    
    var toNSLayoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .width: return NSLayoutConstraint.Attribute.width
        case .height: return NSLayoutConstraint.Attribute.height
        default: return NSLayoutConstraint.Attribute.notAnAttribute
        }
    }
}

public enum LayoutXAxis {
    case left, leading, trailing, right, centerX, none
    
    var toNSLayoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .left: return NSLayoutConstraint.Attribute.left
        case .leading: return NSLayoutConstraint.Attribute.leading
        case .trailing: return NSLayoutConstraint.Attribute.trailing
        case .right: return NSLayoutConstraint.Attribute.right
        case .centerX: return NSLayoutConstraint.Attribute.centerX
        default: return NSLayoutConstraint.Attribute.notAnAttribute
        }
    }
}

public enum LayoutYAxis {
    case top, bottom, centerY, firstBaseline, lastBaseline, none
    
    var toNSLayoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .top: return NSLayoutConstraint.Attribute.top
        case .bottom: return NSLayoutConstraint.Attribute.bottom
        case .centerY: return NSLayoutConstraint.Attribute.centerY
        case .firstBaseline: return NSLayoutConstraint.Attribute.firstBaseline
        case .lastBaseline: return NSLayoutConstraint.Attribute.lastBaseline
        default: return NSLayoutConstraint.Attribute.notAnAttribute
        }
    }
}

public extension UIView {
    public var lcm: LayoutConstraintManager {
        guard let lcm = objc_getAssociatedObject(self, &LCDMKey) as? LayoutConstraintManager else {
            let lcm = LayoutConstraintManager()
            lcm.weakSelf = self
            translatesAutoresizingMaskIntoConstraints = false
            objc_setAssociatedObject(self, &LCDMKey, lcm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            lcm.allLCs()
            return lcm
        }
        return lcm
    }
}

public extension NSLayoutConstraint {
    public func v2(_ secondItem: UIView?) {
        (firstItem as? UIView)?.lcm.lc(a1: firstAttribute, a2: secondAttribute, v2: secondItem, c: constant, m: multiplier, relation: relation)
    }
    
    public func a2(_ attribute: NSLayoutConstraint.Attribute) {
        (firstItem as? UIView)?.lcm.lc(a1: firstAttribute, a2: attribute, v2: secondItem as? UIView, c: constant, m: multiplier, relation: relation)
    }
    
    public func relation(_ r: NSLayoutConstraint.Relation) {
        (firstItem as? UIView)?.lcm.lc(a1: firstAttribute, a2: secondAttribute, v2: secondItem as? UIView, c: constant, m: multiplier, relation: r)
    }
    
    public func m(_ multiplier: CGFloat) {
        (firstItem as? UIView)?.lcm.lc(a1: firstAttribute, a2: secondAttribute, v2: secondItem as? UIView, c: constant, m: multiplier, relation: relation)
    }
}


private var LCDMKey: Void?

public final class LayoutConstraintManager {
    weak var weakSelf: UIView!
    fileprivate weak var tempSecondView: UIView?
    fileprivate var existLCs: [String: NSLayoutConstraint] = [:]
    
    @discardableResult public func allLCs() -> [String: NSLayoutConstraint] {
        let superView = weakSelf.superview!
        existLCs.removeAll()
        for lc in weakSelf.constraints {
            switch (lc.firstAttribute, lc.secondAttribute) {
            case (.width, .notAnAttribute), (.height, .notAnAttribute):
                let addr1 = unsafeBitCast(lc.firstItem, to: Int.self)
                let key = lc.firstAttribute.desc + ":" + addr1.tS
                existLCs[key] = lc
            case (.width, .height), (.height, .width):
                let addr1 = unsafeBitCast(lc.firstItem, to: Int.self)
                let key = lc.firstAttribute.desc + ":" + addr1.tS + "," + lc.secondAttribute.desc + ":" + addr1.tS
                existLCs[key] = lc
            default: break
            }
        }
        for lc in superView.constraints {
            switch (lc.firstItem, lc.secondItem, lc.firstAttribute, lc.secondAttribute) {
            case let (v1, v2, a1, a2) where (v1 === weakSelf || v2 === weakSelf):
                let addr1 = unsafeBitCast(v1, to: Int.self)
                let addr2 = unsafeBitCast(v2, to: Int.self)
                let key = a1.desc + ":" + addr1.tS + "," + a2.desc + ":" + addr2.tS
                existLCs[key] = lc
            default: break
            }
        }
        return existLCs
    }
    
    public func find(_ a1: NSLayoutConstraint.Attribute, v2: AnyObject? = nil, a2: NSLayoutConstraint.Attribute? = nil) -> NSLayoutConstraint? {
        guard !existLCs.isEmpty else { return nil }
        let addr1 = unsafeBitCast(weakSelf, to: Int.self)
        let key: String
        let v2: AnyObject? = v2 ?? weakSelf.superview
        switch (a1, a2) {
        case (.width, nil), (.height, nil):
            // 自身约束
            key = a1.desc + ":" + addr1.tS
        case (.right, .right?), (.trailing, .trailing?), (.bottom, .bottom?), (.right, .centerX?), (.trailing, .centerX?), (.bottom, .centerY?):
            // v1 v2 互换
            let addr2 = unsafeBitCast(v2, to: Int.self)
            key = (a2 ?? a1).desc + ":" + addr2.tS + "," + a1.desc + ":" + addr1.tS
        default:
            let addr2 = unsafeBitCast(v2, to: Int.self)
            key = a1.desc + ":" + addr1.tS + "," + (a2 ?? a1).desc + ":" + addr2.tS
        }
        return existLCs[key]
    }
    
    @discardableResult public func t(_ c: CGFloat = 0, a2: LayoutYAxis = .top, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .top, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func l(_ c: CGFloat = 0, a2: LayoutXAxis = .left, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .left, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func b(_ c: CGFloat = 0, a2: LayoutYAxis = .bottom, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .bottom, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func r(_ c: CGFloat = 0, a2: LayoutXAxis = .right, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .right, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func top(_ c: CGFloat = 0, vc: UIViewController) -> Self {
        let addLC = weakSelf.topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor, constant: c)
        lc(a1: addLC.firstAttribute, a2: addLC.secondAttribute, v1: addLC.firstItem, v2: addLC.secondItem, c: addLC.constant, m: addLC.multiplier, relation: addLC.relation)
        return self
    }
    
    @discardableResult public func bottom(_ c: CGFloat = 0, vc: UIViewController) -> Self {
        let addLC = vc.bottomLayoutGuide.topAnchor.constraint(equalTo: weakSelf.bottomAnchor, constant: c)
        lc(a1: addLC.firstAttribute, a2: addLC.secondAttribute, v1: addLC.firstItem, v2: addLC.secondItem, c: addLC.constant, m: addLC.multiplier, relation: addLC.relation)
        return self
    }
    
    @discardableResult public func lead(_ c: CGFloat = 0, a2: LayoutXAxis = .leading, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .leading, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func trail(_ c: CGFloat = 0, a2: LayoutXAxis = .trailing, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .trailing, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func w(_ c: CGFloat = 0, a2: LayoutDimension = .none ,m: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        lc(a1: .width, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func ww(_ c: CGFloat = 0, a2: LayoutDimension = .width ,m: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        lc(a1: .width, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func h(_ c: CGFloat = 0, a2: LayoutDimension = .none ,m: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        lc(a1: .height, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func hh(_ c: CGFloat = 0, a2: LayoutDimension = .height, m: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        lc(a1: .height, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func midX(_ c: CGFloat = 0, a2: LayoutXAxis = .centerX, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .centerX, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func midY(_ c: CGFloat = 0, a2: LayoutYAxis = .centerY, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        lc(a1: .centerY, a2: a2.toNSLayoutAttribute, c: c, m: m, relation: relation)
        return self
    }
    
    @discardableResult public func v2(_ view: UIView?) -> Self {
        tempSecondView = view
        return self
    }
    
    @discardableResult public func edge(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) -> Self {
        self.t(t).l(l).b(b).r(r)
        return self
    }
    
    @discardableResult
    public func lc(a1: NSLayoutConstraint.Attribute, a2: NSLayoutConstraint.Attribute = .notAnAttribute, v1: AnyObject? = nil, v2: AnyObject? = nil,
            c: CGFloat = 0, m: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint? {
        let lc: NSLayoutConstraint
        let firstObj: AnyObject = v1 ?? weakSelf
        let secObj: AnyObject? = v2 ?? tempSecondView ?? weakSelf.superview
        let addr1 = unsafeBitCast(firstObj, to: Int.self)
        let addr2 = unsafeBitCast(secObj, to: Int.self)
        let key: String
        switch (a1, a2) {
        case (.width, .notAnAttribute), (.height, .notAnAttribute): //self
            lc = NSLayoutConstraint(item: firstObj, attribute: a1, relatedBy: relation,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: m, constant: c)
            key = a1.desc + ":" + addr1.tS
        case (.width, .height), (.height, .width): //aspect
            lc = NSLayoutConstraint(item: firstObj, attribute: a1, relatedBy: relation,
                                    toItem: firstObj, attribute: a2, multiplier: m, constant: c)
            key = a1.desc + ":" + addr1.tS + "," + a2.desc + ":" + addr2.tS
        case (.right, .right), (.bottom, .bottom), (.trailing, .trailing), (.right, .centerX), (.trailing, .centerX), (.bottom, .centerY):
            guard let superview = secObj else { return nil }
            lc = NSLayoutConstraint(item: superview, attribute: a2, relatedBy: relation,
                                    toItem: firstObj, attribute: a1, multiplier: m, constant: c)
            key = a2.desc + ":" + addr2.tS + "," + a1.desc + ":" + addr1.tS
        default:
            lc = NSLayoutConstraint(item: firstObj, attribute: a1, relatedBy: relation,
                                    toItem: secObj, attribute: a2, multiplier: m, constant: c)
            key = a1.desc + ":" + addr1.tS + "," + a2.desc + ":" + addr2.tS
        }
        existLCs.removeValue(forKey: key)?.isActive = false
        existLCs[key] = lc
        lc.isActive = true
        return lc
    }
    
    @discardableResult
    public func update(on: UIView? = nil, duration: TimeInterval = 0, animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) -> Self {
        allLCs()
        let updateView = on ?? weakSelf.superview
        if duration > 0 {
            UIView.animate(withDuration: duration, animations: {
                animations?()
                updateView?.layoutIfNeeded()
            }, completion: { (result) in
                completion?()
            })
        } else {
            updateView?.layoutIfNeeded()
            completion?()
        }
        return self
    }
}

extension NSLayoutConstraint.Attribute {
    public var desc: String {
        switch self {
        case .left: return "left"
        case .right: return "right"
        case .top: return "top"
        case .bottom: return "bottom"
        case .leading: return "leading"
        case .trailing: return "trailing"
        case .width: return "width"
        case .height: return "height"
        case .centerX: return "centerX"
        case .centerY: return "centerY"
        case .lastBaseline: return "lastBaseline"
        case .firstBaseline: return "firstBaseline"
        case .leftMargin: return "leftMargin"
        case .rightMargin: return "rightMargin"
        case .topMargin: return "topMargin"
        case .bottomMargin: return "bottomMargin"
        case .leadingMargin: return "leadingMargin"
        case .trailingMargin: return "trailingMargin"
        case .centerXWithinMargins: return "centerXWithinMargins"
        case .centerYWithinMargins: return "centerYWithinMargins"
        case .notAnAttribute: return "notAnAttribute"
        }
    }
}
