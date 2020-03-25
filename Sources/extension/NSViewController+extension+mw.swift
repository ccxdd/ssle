//
//  NSViewController+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2020/3/24.
//  Copyright © 2020 陈晓东. All rights reserved.
//

#if os(macOS)
import Cocoa

public extension NSViewController {
    
    /// toWindow
    func toWindow() -> NSWindow {
        let win = NSWindow(contentViewController: self)
        return win
    }
    
    /// toWindowController
    func toWindowController() -> NSWindowController {
        let wvc = NSWindowController(window: toWindow())
        return wvc
    }
}

public extension NSAlert {
    static func alert(msg: String, text: String = "", buttons: [String] = [], style: NSAlert.Style = .informational,
                      window: NSWindow? = nil, runModal: Bool = false,
                      callback: GenericsClosure<NSApplication.ModalResponse>? = nil) {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = text
        alert.alertStyle = style
        for title in buttons {
            alert.addButton(withTitle: title)
        }
        if runModal {
            let resp = alert.runModal()
            callback?(resp)
        } else {
            guard let win = NSApplication.shared.windows.first else { return }
            alert.beginSheetModal(for: window ?? win) { resp in
                callback?(resp)
            }
        }
    }
}
#endif
