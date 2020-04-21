//
//  UIView+Layout+Anchor.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2019/9/16.
//  Copyright © 2019 陈晓东. All rights reserved.
//

#if os(macOS)
import AppKit
public typealias MWCrossPlatformView = NSView
#else
import UIKit
public typealias MWCrossPlatformView = UIView
#endif

private var MWLayoutKey: Void?

public final class MWLayout {
    internal weak var selfSelf: MWCrossPlatformView!
    internal weak var secondView: MWCrossPlatformView?
    fileprivate var lcDict: [String: NSLayoutConstraint] = [:]
}

public extension MWCrossPlatformView {
    var mwl: MWLayout {
        guard let mwl = objc_getAssociatedObject(self, &MWLayoutKey) as? MWLayout else {
            translatesAutoresizingMaskIntoConstraints = false
            let mwl = MWLayout()
            mwl.selfSelf = self
            objc_setAssociatedObject(self, &MWLayoutKey, mwl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return mwl
        }
        return mwl
    }
}

public extension MWLayout {
    fileprivate var superView: MWCrossPlatformView {
        return selfSelf.superview!
    }
    
    @available(OSX 10.11, *)
    private func saveLC<T>(firstAnchor: NSLayoutAnchor<T>, secondAnchor: NSLayoutAnchor<T>?, lc: NSLayoutConstraint) where T: AnyObject {
        let f = unsafeBitCast(firstAnchor, to: Int.self)
        let s = unsafeBitCast(secondAnchor, to: Int.self)
        let key = f.tS + s.tS
        let key2 = s.tS + f.tS
        lcDict.removeValue(forKey: key)?.isActive = false
        lcDict.removeValue(forKey: key2)?.isActive = false
        lcDict[key] = lc
        lc.isActive = true
    }
    
    @available(OSX 10.11, *)
    func find<T>(_ a1: NSLayoutAnchor<T>, a2: NSLayoutAnchor<T>? = nil) -> NSLayoutConstraint? where T: AnyObject {
        let f = unsafeBitCast(a1, to: Int.self)
        let s = unsafeBitCast(a2, to: Int.self)
        let key = f.tS + s.tS
        let key2 = s.tS + f.tS
        if let l = lcDict[key] {
            return l
        } else {
            return lcDict[key2]
        }
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func layout<T>(_ a1: NSLayoutAnchor<T>, a2: NSLayoutAnchor<T>?, relation: NSLayoutConstraint.Relation = .equal, c: CGFloat = 0, m: CGFloat = 1) -> NSLayoutConstraint? where T: AnyObject {
        var lc: NSLayoutConstraint?
        switch a2 {
        case nil:
            if let a = a1 as? NSLayoutDimension {
                switch relation {
                case .equal:
                    lc = a.constraint(equalToConstant: c)
                case .greaterThanOrEqual:
                    lc = a.constraint(greaterThanOrEqualToConstant: c)
                case .lessThanOrEqual:
                    lc = a.constraint(lessThanOrEqualToConstant: c)
                @unknown default: return nil
                }
            }
        default:
            switch relation {
            case .equal:
                lc = a1.constraint(equalTo: a2!, constant: c).setM(m)
            case .greaterThanOrEqual:
                lc = a1.constraint(greaterThanOrEqualTo: a2!, constant: c).setM(m)
            case .lessThanOrEqual:
                lc = a1.constraint(lessThanOrEqualTo: a2!, constant: c).setM(m)
            @unknown default: return nil
            }
        }
        if lc != nil {
            saveLC(firstAnchor: a1, secondAnchor: a2, lc: lc!)
        }
        return lc
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func l(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.leadingAnchor ?? superView.leadingAnchor
        layout(selfSelf.leadingAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func left(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.leftAnchor ?? superView.leftAnchor
        layout(selfSelf.leftAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func r(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.trailingAnchor ?? superView.trailingAnchor
        layout(selfSelf.trailingAnchor, a2: secondAnchor, relation: relation, c: -c, m: 1)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func right(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.rightAnchor ?? superView.rightAnchor
        layout(selfSelf.rightAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func midX(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutXAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.centerXAnchor ?? superView.centerXAnchor
        layout(selfSelf.centerXAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func t(_ c: CGFloat = 0, anchor: NSLayoutYAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.topAnchor ?? superView.topAnchor
        layout(selfSelf.topAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func b(_ c: CGFloat = 0, anchor: NSLayoutYAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.bottomAnchor ?? superView.bottomAnchor
        layout(selfSelf.bottomAnchor, a2: secondAnchor, relation: relation, c: -c, m: 1)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func midY(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutYAxisAnchor? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = anchor ?? secondView?.centerYAnchor ?? superView.centerYAnchor
        layout(selfSelf.centerYAnchor, a2: secondAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func w(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutDimension? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        layout(selfSelf.widthAnchor, a2: anchor ?? secondView?.widthAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    @available(OSX 10.11, *)
    @discardableResult
    func h(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutDimension? = nil, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        layout(selfSelf.heightAnchor, a2: anchor ?? secondView?.heightAnchor, relation: relation, c: c, m: m)
        return self
    }
    
    #if os(iOS)
    @available (iOS 11.0, *)
    @discardableResult
    func safeL(_ c: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = secondView?.safeAreaLayoutGuide.leadingAnchor ?? superView.safeAreaLayoutGuide.leadingAnchor
        layout(selfSelf.leadingAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available (iOS 11.0, *)
    @discardableResult
    func safeLeft(_ c: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = secondView?.safeAreaLayoutGuide.leftAnchor ?? superView.safeAreaLayoutGuide.leftAnchor
        layout(selfSelf.leftAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available (iOS 11.0, *)
    @discardableResult
    func safeR(_ c: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = secondView?.safeAreaLayoutGuide.trailingAnchor ?? superView.safeAreaLayoutGuide.trailingAnchor
        layout(selfSelf.trailingAnchor, a2: secondAnchor, relation: relation, c: -c, m: 1)
        return self
    }
    
    @available (iOS 11.0, *)
    @discardableResult
    func safeRight(_ c: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = secondView?.safeAreaLayoutGuide.rightAnchor ?? superView.safeAreaLayoutGuide.rightAnchor
        layout(selfSelf.rightAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available (iOS 11.0, *)
    @discardableResult
    func safeT(_ c: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = secondView?.safeAreaLayoutGuide.topAnchor ?? superView.safeAreaLayoutGuide.topAnchor
        layout(selfSelf.topAnchor, a2: secondAnchor, relation: relation, c: c, m: 1)
        return self
    }
    
    @available (iOS 11.0, *)
    @discardableResult
    func safeB(_ c: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> Self {
        let secondAnchor = secondView?.safeAreaLayoutGuide.bottomAnchor ?? superView.safeAreaLayoutGuide.bottomAnchor
        layout(selfSelf.bottomAnchor, a2: secondAnchor, relation: relation, c: -c, m: 1)
        return self
    }
    
    @discardableResult
    func edge(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) -> Self {
        edge(inset: UIEdgeInsets(top: t, left: l, bottom: b, right: r))
        return self
    }
    
    @discardableResult
    func edge(inset: UIEdgeInsets) -> Self {
        self.t(inset.top).l(inset.left).b(inset.bottom).r(inset.right)
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func safeEdge(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) -> Self {
        safeEdge(inset: UIEdgeInsets(top: t, left: l, bottom: b, right: r))
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func safeEdge(inset: UIEdgeInsets) -> Self {
        self.t(inset.top, anchor: superView.safeAreaLayoutGuide.topAnchor)
            .l(inset.left, anchor: superView.safeAreaLayoutGuide.leadingAnchor)
            .b(inset.bottom, anchor: superView.safeAreaLayoutGuide.bottomAnchor)
            .r(inset.right, anchor: superView.safeAreaLayoutGuide.trailingAnchor)
        return self
    }
    
    @discardableResult
    func refresh(_ on: UIView? = nil, duration: TimeInterval = 0, animations: (() -> Void)? = nil,
                 completion: (() -> Void)? = nil) -> Self {
        let refreshView = on ?? superView
        if duration > 0 {
            UIView.animate(withDuration: duration, animations: {
                animations?()
                refreshView.layoutIfNeeded()
            }, completion: { (result) in
                completion?()
            })
        } else {
            refreshView.layoutIfNeeded()
            completion?()
        }
        return self
    }
    #endif
}

public extension NSLayoutConstraint {
    @discardableResult
    func setM(_ multiplier: CGFloat) -> NSLayoutConstraint {
        isActive = false
        let newLC = NSLayoutConstraint(item: firstItem!, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
        return newLC
    }
}
