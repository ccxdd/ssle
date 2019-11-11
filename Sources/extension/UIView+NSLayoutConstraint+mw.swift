//
//  UIView+NSLayoutConstraint+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 16/6/18.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

#if os(iOS)
import UIKit

public enum LayoutDimension {
    case width, height
    
    var toNSLayoutAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .width: return NSLayoutConstraint.Attribute.width
        case .height: return NSLayoutConstraint.Attribute.height
        default: return NSLayoutConstraint.Attribute.notAnAttribute
        }
    }
    
    func toAnchor(obj: UIView?) -> NSLayoutDimension? {
        switch self {
        case .width: return obj?.widthAnchor
        case .height: return obj?.heightAnchor
        default: return nil
        }
    }
}

public enum LayoutXAxis {
    case left, leading, trailing, right, centerX
    
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
    
    func toAnchor(obj: UIView?) -> NSLayoutXAxisAnchor? {
        switch self {
        case .left: return obj?.leftAnchor
        case .leading: return obj?.leadingAnchor
        case .trailing: return obj?.trailingAnchor
        case .right: return obj?.rightAnchor
        case .centerX: return obj?.centerXAnchor
        default: return nil
        }
    }
}

public enum LayoutYAxis {
    case top, bottom, centerY, firstBaseline, lastBaseline
    
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
    
    func toAnchor(obj: UIView?) -> NSLayoutYAxisAnchor? {
        switch self {
        case .top: return obj?.topAnchor
        case .bottom: return obj?.bottomAnchor
        case .centerY: return obj?.centerYAnchor
        case .firstBaseline: return obj?.firstBaselineAnchor
        case .lastBaseline: return obj?.lastBaselineAnchor
        default: return nil
        }
    }
}

public extension NSLayoutConstraint.Attribute {
    var desc: String {
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

public extension MWLayout {
    @discardableResult
    public func v2(_ view: UIView?) -> Self {
        secondView = view
        return self
    }
    
    @discardableResult
    public func t(_ c: CGFloat = 0, a2: LayoutYAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.topAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func l(_ c: CGFloat = 0, a2: LayoutXAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.leadingAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func left(_ c: CGFloat = 0, a2: LayoutXAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.leftAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func b(_ c: CGFloat = 0, a2: LayoutYAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.bottomAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func r(_ c: CGFloat = 0, a2: LayoutXAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.trailingAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func right(_ c: CGFloat = 0, a2: LayoutXAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.rightAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func w(_ c: CGFloat = 0, a2: LayoutDimension?, m: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = a2?.toAnchor(obj: secondView)
        layout(selfSelf.widthAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func h(_ c: CGFloat = 0, a2: LayoutDimension? ,m: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = a2?.toAnchor(obj: secondView)
        layout(selfSelf.heightAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func midX(_ c: CGFloat = 0, a2: LayoutXAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.centerXAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @discardableResult
    public func midY(_ c: CGFloat = 0, a2: LayoutYAxis, relation: NSLayoutConstraint.Relation = .equal, m: CGFloat = 1) -> Self {
        let secondAnchor = a2.toAnchor(obj: secondView ?? selfSelf.superview!)
        layout(selfSelf.centerYAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
}
#endif
