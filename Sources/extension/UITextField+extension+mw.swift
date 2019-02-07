//
//  UITextField+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/4/21.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import UIKit

private var textFieldAdditionKey: Void?

private final class TextFieldAddition: NSObject {
    var minLen: Int = 0
    var maxLen: Int = Int.max
    var maxValue: String?
    var decimalLen: Int = -1
    var regularPattern: String?
    var didChangeClosure: ((String) -> Void)?
    var inputCategory: UITextField.InputCategory = .none
    weak var enabledButton: UIButton?
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        let t: String = sender.text ?? ""
        guard t.count <= maxLen else {
            changeCallback(sender: sender, isDelete: true)
            return }
        switch inputCategory {
        case .decimal:
            guard t.isDecimal, !t.hasPrefix("."), !t.hasPrefix("00"), t.components(separatedBy: ".").count < 3 else {
                changeCallback(sender: sender, isDelete: true)
                return }
            guard t.decimalNum <= decimalLen, decimalLen != -1 else {
                changeCallback(sender: sender, isDelete: true)
                return }
        case .digit:
            guard t.isInt else {
                changeCallback(sender: sender, isDelete: true)
                return }
        case .none:
            changeCallback(sender: sender)
            return
        }
        if t.count == 2, t.hasPrefix("0"), t != "0." {
            sender.text = t.last?.description
        }
        if maxValue != nil, t.tF > maxValue!.tF {
            sender.text = maxValue
        }
        changeCallback(sender: sender)
    }
    
    private func changeCallback(sender: UITextField, isDelete: Bool = false) {
        if isDelete {
            sender.deleteBackward()
        }
        didChangeClosure?(sender.text ?? "")
        enabledButton?.refreshEnabled()
    }
}

public extension UITextField {
    public enum InputCategory {
        case none, decimal, digit
    }
    
    private var addition: TextFieldAddition {
        guard let addition = objc_getAssociatedObject(self, &textFieldAdditionKey) as? TextFieldAddition else {
            let addition = TextFieldAddition()
            objc_setAssociatedObject(self, &textFieldAdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    
    @IBAction public func showPwd(_ sender: UIButton) {
        isSecureTextEntry = !isSecureTextEntry
        sender.isSelected = !sender.isSelected
    }
    
    @IBInspectable public var minLen: Int {
        get {
            return addition.minLen
        }
        set {
            addition.minLen = newValue
        }
    }
    
    @IBInspectable public var maxLen: Int {
        get {
            return addition.maxLen
        }
        set {
            addition.maxLen = newValue
        }
    }
    
    @IBInspectable public var decimal: Int {
        get {
            return addition.decimalLen
        }
        set {
            addition.decimalLen = newValue
        }
    }
    
    @IBInspectable public var regularPattern: String? {
        get {
            return addition.regularPattern
        }
        set {
            addition.regularPattern = newValue
        }
    }
    
    public var textLength: Int {
        return text?.count ?? 0
    }
    
    public var inputValid: Bool {
        switch addition.inputCategory {
        case .none:
            if let r = regularPattern {
                return textLength > 0 && textLength >= minLen && textLength <= maxLen && text?.matchRegular(r) == true
            } else {
                return textLength > 0 && textLength >= minLen && textLength <= maxLen
            }
        default:
            return (text?.tF ?? 0) > 0
        }
    }
    
    public func didChange(closure: @escaping (String) -> Void) {
        addition.didChangeClosure = closure
        event(.editingChanged) { [weak self] in self?.addition.textFieldDidChange($0 as! UITextField) }
    }
    
    public func didBegin(closure: @escaping (String) -> Void) {
        event(.editingDidBegin) { [weak self] t in
            closure(self?.text ?? "")
        }
    }
    
    public func didEnd(closure: @escaping (String) -> Void) {
        event(.editingDidEnd) { [weak self] t in
            closure(self?.text ?? "")
        }
    }
    
    @discardableResult public func fillMax(value: String?) -> Self {
        addition.maxValue = value
        if (text?.tF ?? 0) > (value?.tF ?? 0) {
            text = value
        }
        return self
    }
    
    @discardableResult public func min(len: Int) -> Self {
        addition.minLen = len
        return self
    }
    
    @discardableResult public func max(len: Int) -> Self {
        addition.maxLen = len
        return self
    }
    
    @discardableResult public func decimal(len: Int) -> Self {
        addition.decimalLen = len
        return self
    }
    
    @discardableResult public func input(categary: InputCategory) -> Self {
        addition.inputCategory = categary
        switch categary {
        case .decimal:
            keyboardType = .decimalPad
        case .digit:
            keyboardType = .numberPad
        default: break
        }
        return self
    }
}
