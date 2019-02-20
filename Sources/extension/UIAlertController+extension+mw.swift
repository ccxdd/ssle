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
    public class func alert(title: String? = "", message: String?, buttons: String..., destructive: Int = -1, closure: ((Int) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (idx, title) in buttons.enumerated() {
            let style: UIAlertAction.Style = destructive == idx ? .destructive : .default
            let action = UIAlertAction(title: title, style: style, handler: { (action) in
                closure?(idx)
            })
            alert.addAction(action)
        }
        DispatchQueue.main.async {
            UIViewController.currentVC?.present(vc: alert)
        }
    }
    
    public class func sheet(title: String? = nil, message: String? = nil, buttons: [String], closure: ((Int) -> Void)? = nil) {
        let sheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (idx, title) in buttons.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: { (action) in
                closure?(idx)
            })
            sheet.addAction(action)
        }
        let cancelAct = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancelAct)
        DispatchQueue.main.async {
            UIViewController.currentVC?.present(vc: sheet)
        }
    }
    
    public static func alertPwd(title: String? = "", message: String?, placeholder: String?, buttons: String..., destructive: Int = -1,
                         closure: ((String, Int) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = placeholder
            field.isSecureTextEntry = true
        }
        for (idx, title) in buttons.enumerated() {
            let style: UIAlertAction.Style = destructive == idx ? .destructive : .default
            let action = UIAlertAction(title: title, style: style, handler: { (action) in
                if let text = alert.textFields?.first?.text, text.count > 0 {
                    closure?(text, idx)
                }
                
            })
            alert.addAction(action)
        }
        DispatchQueue.main.async {
            UIViewController.currentVC?.present(vc: alert)
        }
    }
}
#endif
