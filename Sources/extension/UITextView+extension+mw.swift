//
//  UITextView+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2018/10/9.
//  Copyright © 2018 陈晓东. All rights reserved.
//

#if os(iOS)
import UIKit

private var textViewAdditionKey: Void?

private class TextViewAddition: NSObject, UITextViewDelegate {
    var minLen: Int = 0
    var maxLen: Int = Int.max
    var left: CGFloat = 8
    var top: CGFloat = 8
    var didChangeClosure: ((String) -> Void)?
    var placeholderLabel: UILabel!
    weak var enabledButton: UIButton?
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = textView.text.count > 0
        changeCallback(sender: textView, isDelete: textView.text.count > maxLen)
    }
    
    private func changeCallback(sender: UITextView, isDelete: Bool = false) {
        if isDelete {
            sender.deleteBackward()
        }
        didChangeClosure?(sender.text ?? "")
        enabledButton?.refreshEnabled()
    }
}

public extension UITextView {
    fileprivate var addition: TextViewAddition {
        guard let addition = objc_getAssociatedObject(self, &textViewAdditionKey) as? TextViewAddition else {
            let addition = TextViewAddition()
            let lab = UILabel().addTo(view: self)
            lab.numberOfLines = 0
            lab.lcm.t(addition.top).lead(addition.left).w(frame.width - 8)
            lab.font = font
            lab.textColor = UIColor.lightGray
            lab.isUserInteractionEnabled = false
            addition.placeholderLabel = lab
            delegate = addition
            objc_setAssociatedObject(self, &textViewAdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return addition
        }
        return addition
    }
    
    @IBOutlet var enabledButton: UIButton? {
        set {
            addition.enabledButton = newValue
        }
        get {
            return addition.enabledButton
        }
    }
    
    @IBInspectable var minLen: Int {
        get {
            return addition.minLen
        }
        set {
            addition.minLen = newValue
        }
    }
    
    @IBInspectable var maxLen: Int {
        get {
            return addition.maxLen
        }
        set {
            addition.maxLen = newValue
        }
    }
    
    var placeholder: String? {
        set {
            addition.placeholderLabel.text = newValue
        }
        get {
            return addition.placeholderLabel.text
        }
    }
    
    var textLength: Int {
        return text.count
    }
    
    func didChange(closure: @escaping (String) -> Void) {
        addition.didChangeClosure = closure
    }
    
    var inputValid: Bool {
        return textLength > 0 && textLength >= minLen && textLength <= maxLen
    }
    
    @discardableResult func min(len: Int) -> Self {
        addition.minLen = len
        return self
    }
    
    @discardableResult func max(len: Int) -> Self {
        addition.maxLen = len
        return self
    }
}
#endif

