//
//  UIView+Layout+Anchor.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2019/9/16.
//  Copyright © 2019 陈晓东. All rights reserved.
//

#if os(iOS)

private var MWLayoutKey: Void?

public final class MWLayout {
    weak var selfSelf: UIView!
    fileprivate var lcArray: [String: NSLayoutConstraint] = [:]
}

public extension UIView {
    var ls: MWLayout {
        guard let mwl = objc_getAssociatedObject(self, &MWLayoutKey) as? MWLayout else {
            translatesAutoresizingMaskIntoConstraints = false
            let mwl = MWLayout()
            mwl.selfSelf = self
            return mwl
        }
        return mwl
    }
}

public extension MWLayout {
    private var toView: UIView {
        return selfSelf.superview!
    }
    
    private func saveLC<T>(firstAnchor: NSLayoutAnchor<T>, secondAnchor: NSLayoutAnchor<T>?, lc: NSLayoutConstraint) where T: AnyObject {
        let f = unsafeBitCast(firstAnchor, to: Int.self)
        let s = unsafeBitCast(secondAnchor, to: Int.self)
        let key = f.tS + s.tS
        let key2 = s.tS + f.tS
        lcArray.removeValue(forKey: key)?.isActive = false
        lcArray.removeValue(forKey: key2)?.isActive = false
        lcArray[key] = lc
        lc.isActive = true
    }
    
    @discardableResult
    func l(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.leadingAnchor
        let lc = selfSelf.leadingAnchor.constraint(equalTo: secondAnchor, constant: c)
        saveLC(firstAnchor: selfSelf.leadingAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func left(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.leftAnchor
        let lc = selfSelf.leftAnchor.constraint(equalTo: secondAnchor, constant: c)
        saveLC(firstAnchor: selfSelf.leadingAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func r(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.trailingAnchor
        let lc = selfSelf.trailingAnchor.constraint(equalTo: secondAnchor, constant: -c)
        saveLC(firstAnchor: selfSelf.trailingAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func right(_ c: CGFloat = 0, anchor: NSLayoutXAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.rightAnchor
        let lc = selfSelf.rightAnchor.constraint(equalTo: secondAnchor, constant: -c)
        saveLC(firstAnchor: selfSelf.rightAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func t(_ c: CGFloat = 0, anchor: NSLayoutYAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.topAnchor
        let lc = selfSelf.topAnchor.constraint(equalTo: secondAnchor, constant: c)
        saveLC(firstAnchor: selfSelf.topAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func b(_ c: CGFloat = 0, anchor: NSLayoutYAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.bottomAnchor
        let lc = selfSelf.bottomAnchor.constraint(equalTo: secondAnchor, constant: -c)
        saveLC(firstAnchor: selfSelf.bottomAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func midX(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutXAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.centerXAnchor
        let lc = selfSelf.centerXAnchor.constraint(equalTo: secondAnchor, constant: c).setM(m)
        saveLC(firstAnchor: selfSelf.centerXAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func midY(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutYAxisAnchor? = nil) -> Self {
        let secondAnchor = anchor ?? toView.centerYAnchor
        let lc = selfSelf.centerYAnchor.constraint(equalTo: secondAnchor, constant: c).setM(m)
        saveLC(firstAnchor: selfSelf.centerYAnchor, secondAnchor: secondAnchor, lc: lc)
        return self
    }
    
    @discardableResult
    func w(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutDimension? = nil) -> Self {
        if anchor == nil {
            let lc = selfSelf.widthAnchor.constraint(equalToConstant: c).setM(m)
            saveLC(firstAnchor: selfSelf.widthAnchor, secondAnchor: nil, lc: lc)
        } else {
            let lc = selfSelf.widthAnchor.constraint(equalTo: anchor!, multiplier: m, constant: c)
            saveLC(firstAnchor: selfSelf.widthAnchor, secondAnchor: anchor, lc: lc)
        }
        return self
    }
    
    @discardableResult
    func h(_ c: CGFloat = 0, m: CGFloat = 1, anchor: NSLayoutDimension? = nil) -> Self {
        if anchor == nil {
            let lc = selfSelf.heightAnchor.constraint(equalToConstant: c).setM(m)
            saveLC(firstAnchor: selfSelf.heightAnchor, secondAnchor: nil, lc: lc)
        } else {
            let lc = selfSelf.heightAnchor.constraint(equalTo: anchor!, multiplier: m, constant: c)
            saveLC(firstAnchor: selfSelf.heightAnchor, secondAnchor: anchor, lc: lc)
        }
        return self
    }
    
    @discardableResult
    func edge(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) -> Self {
        self.t(t).l(l).b(b).r(r)
        return self
    }
    
    @discardableResult
    func refresh(_ on: UIView? = nil, duration: TimeInterval = 0, animations: (() -> Void)? = nil,
                 completion: (() -> Void)? = nil) -> Self {
        let refreshView = on ?? toView
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
}

public extension NSLayoutConstraint {
    @discardableResult
    func setM(_ multiplier: CGFloat) -> NSLayoutConstraint {
        isActive = false
        let newLC = NSLayoutConstraint(item: firstItem!, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
        return newLC
    }
}
#endif
