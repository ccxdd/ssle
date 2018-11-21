//
//  UITextView+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2018/10/9.
//  Copyright © 2018 陈晓东. All rights reserved.
//

import UIKit

private var textViewAdditionKey: Void?

private class TextViewAddition: NSObject, UITextViewDelegate {
    var minLen: Int = Int.max
    var maxLen: Int = 0
    var left: CGFloat = 8
    var top: CGFloat = 8
    var didChangeClosure: ((String) -> Void)?
    weak var weakField: UITextView!
    var placeholderLabel: UILabel!
    weak var enabledButton: UIButton?
    
    @objc fileprivate func textViewDidChange() {
        placeholderLabel?.isHidden = weakField.text.count > 0
        didChangeClosure?(weakField.text)
        enabledButton?.refreshEnabled()
    }
    
    func checkLengthCondition() -> Bool {
        guard let len = weakField?.text.count, len >= minLen, len <= maxLen else { return false }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count <= maxLen || maxLen == 0 {
            return true
        }
        return false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UITextView {
    fileprivate var addition: TextViewAddition {
        guard let addition = objc_getAssociatedObject(self, &textViewAdditionKey) as? TextViewAddition else {
            let addition = TextViewAddition()
            addition.weakField = self
            let lab = UILabel().addTo(view: self)
            lab.lcm.t(addition.top).l(addition.left)
            lab.font = font
            lab.textColor = UIColor.lightGray
            lab.isUserInteractionEnabled = false
            addition.placeholderLabel = lab
            delegate = addition
            NotificationCenter.default.addObserver(addition, selector: #selector(addition.textViewDidChange),
                                                   name: UITextView.textDidChangeNotification, object: nil)
            objc_setAssociatedObject(self, &textViewAdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return addition
        }
        return addition
    }
    
    @IBOutlet public var enabledButton: UIButton? {
        set {
            addition.enabledButton = newValue
        }
        get {
            return addition.enabledButton
        }
    }
    
    public var placeholder: String? {
        set {
            addition.placeholderLabel.text = newValue
        }
        get {
            return addition.placeholderLabel.text
        }
    }
    
    public var textLength: Int {
        return text.count
    }
    
    public func didChange(closure: @escaping (String) -> Void) {
        addition.didChangeClosure = closure
    }
}

