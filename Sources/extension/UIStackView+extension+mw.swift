//
//  UIStackView+extension+mw.swift
//  SSLE
//
//  Created by 陈晓东 on 2018/11/27.
//  Copyright © 2018 陈晓东. All rights reserved.
//

#if os(iOS)
import UIKit

private var AdditionKey: Void?

public extension UIStackView {
    public struct Row {
        var rowView: UIView?
        var contentView: UIView?
    }
    
    private var addition: StackViewAddition {
        if let addition = objc_getAssociatedObject(self, &AdditionKey) as? StackViewAddition {
            return addition
        } else {
            let addition = StackViewAddition()
            objc_setAssociatedObject(self, &AdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return addition
        }
    }
    
    @discardableResult
    public func addRow(view: UIView?) -> Self {
        guard let v = view else { return self }
        var row = Row()
        row.rowView = UIView()
        row.contentView = v
        row.rowView?.addSubview(v)
        v.lcm.edge()
        addArrangedSubview(row.rowView!)
        addition.rows.append(row)
        addition.index = addition.rows.count - 1
        return self
    }
    
    @discardableResult
    public func inset(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) -> Self {
        addition.rows.at(addition.index)?.contentView?.lcm.t(t).l(l).b(b).r(r)
        return self
    }
    
    @discardableResult
    public func content(bg: UIColor) -> Self {
        addition.rows.at(addition.index)?.contentView?.backgroundColor = bg
        return self
    }
    
    @discardableResult
    public func row(bg: UIColor) -> Self {
        addition.rows.at(addition.index)?.rowView?.backgroundColor = bg
        return self
    }
    
    @discardableResult
    public func row(height: CGFloat) -> Self {
        addition.rows.at(addition.index)?.rowView?.lcm.h(height)
        return self
    }
    
    @discardableResult
    public func content(height: CGFloat) -> Self {
        addition.rows.at(addition.index)?.contentView?.lcm.h(height)
        return self
    }
    
    @discardableResult
    public func get(row: Int) -> Self {
        addition.index = row
        return self
    }
    
    @discardableResult
    public func remove(row: Int) -> Self {
        guard let v = arrangedSubviews.at(row) else { return self }
        removeArrangedSubview(v)
        addition.rows.remove(at: row)
        return self
    }
    
    @discardableResult
    public func hide(_ flag: Bool) -> Self {
        arrangedSubviews.at(addition.index)?.isHidden = flag
        return self
    }
}

private final class StackViewAddition {
    var index: Int = 0
    var rows: [UIStackView.Row] = []
}
#endif
