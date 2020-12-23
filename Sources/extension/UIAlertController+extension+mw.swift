//
//  UIAlertController+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/11/1.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

#if os(iOS)
import UIKit
import AVFoundation

public extension UIAlertController {
    
    enum AlertFieldType {
        case field(String)
        case pwd(String)
        case btn(String)
        case destructive(String)
    }
    
    class func alert(title: String? = "", message: String?, buttons: String..., destructive: Int = -1, closure: ((Int) -> Void)? = nil) {
        var fields: [AlertFieldType] = []
        for (i, b) in buttons.enumerated() {
            fields.append(i == destructive ? .destructive(b) : .btn(b))
        }
        alertCustomize(title:title, message: message, fields: fields) { _, idx in
            closure?(idx)
        }
    }
    
    class func sheet(title: String? = nil, message: String? = nil, buttons: [String], popoverSender: UIView? = nil, closure: ((Int) -> Void)? = nil) {
        let sheetVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (idx, title) in buttons.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: { (action) in
                closure?(idx)
            })
            sheetVC.addAction(action)
        }
        let cancelAct = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        sheetVC.addAction(cancelAct)
        if let popSender = popoverSender {
            if let popoverController = sheetVC.popoverPresentationController {
                popoverController.sourceView = popSender
                popoverController.sourceRect = CGRect(x: popSender.bounds.midX, y: popSender.bounds.midY, width: 0, height: 0)
            }
        }
        DispatchQueue.main.async {
            UIViewController.currentVC?.present(vc: sheetVC)
        }
    }
    
    static func alertPwd(title: String? = "", message: String?, placeholder: String?, buttons: String..., destructive: Int = -1,
                                closure: ((String, Int) -> Void)? = nil) {
        var fields: [AlertFieldType] = [.pwd(placeholder ?? "")]
        for (i, b) in buttons.enumerated() {
            fields.append(i == destructive ? .destructive(b) : .btn(b))
        }
        alertCustomize(title:title, message: message, fields: fields) { fields, idx in
            closure?(fields.first!, idx)
        }
    }
    
    static func alertCustomize(title: String? = "", message: String?,
                                      fields: [AlertFieldType], closure: (([String], Int) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var btnTitlesArr: [String] = []
        for f in fields {
            switch f {
            case .field(let text), .pwd(let text):
                alert.addTextField { (field) in
                    field.placeholder = text
                    if case .pwd(_) = f {
                        field.isSecureTextEntry = true
                    }
                }
            case .btn(let text), .destructive(let text):
                var style: UIAlertAction.Style = .default
                if case .destructive(_) = f {
                    style = .destructive
                }
                btnTitlesArr.append(text)
                let action = UIAlertAction(title: text, style: style, handler: { (action) in
                    var textArr: [String] = []
                    for f in alert.textFields! {
                        textArr.append(f.text ?? "")
                    }
                    closure?(textArr, btnTitlesArr.firstIndex(of: action.title!) ?? 0)
                })
                alert.addAction(action)
            }
        }
        DispatchQueue.main.async {
            UIViewController.currentVC?.present(vc: alert)
        }
    }
}
#endif
