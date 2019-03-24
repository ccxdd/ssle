//
//  UIControl+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2019/2/4.
//  Copyright © 2019 陈晓东. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIControl {
    
    public func event<T>(_ e: UIControl.Event, handle: @escaping (T) -> Void) where T: UIControl {
        addTarget(self, action: UIButton.eventToSEL(e), for: e)
        cbm.controlEventDict[e.rawValue] = handle
    }
    
    @objc private func eventTouchDown(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchDown.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchDownRepeat(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchDownRepeat.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchDragInside(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchDragInside.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchDragOutside(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchDragOutside.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchDragEnter(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchDragEnter.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchDragExit(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchDragExit.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchUpInside(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchUpInside.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchUpOutside(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchUpOutside.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventTouchCancel(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.touchCancel.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventValueChanged(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.valueChanged.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventPrimaryActionTriggered(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.primaryActionTriggered.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventEditingDidBegin(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.editingDidBegin.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventEditingChanged(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.editingChanged.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventEditingDidEnd(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.editingDidEnd.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventEditingDidEndOnExit(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.editingDidEndOnExit.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventAllTouchEvents(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.allTouchEvents.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventAllEditingEvents(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.allEditingEvents.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventApplicationReserved(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.applicationReserved.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventSystemReserved(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.systemReserved.rawValue] as? GenericsClosure)?(sender) }
    @objc private func eventAllEvents(_ sender: UIControl) { (cbm.controlEventDict[UIControl.Event.allEvents.rawValue] as? GenericsClosure)?(sender) }
    
    private static func eventToSEL(_ e: UIControl.Event) -> Selector {
        switch e {
        case .touchDown:
            return #selector(eventTouchDown(_:))
        case .touchDownRepeat:
            return #selector(eventTouchDownRepeat(_:))
        case .touchDragInside:
            return #selector(eventTouchDragInside(_:))
        case .touchDragOutside:
            return #selector(eventTouchUpOutside(_:))
        case .touchDragEnter:
            return #selector(eventTouchDragEnter(_:))
        case .touchDragExit:
            return #selector(eventTouchDragExit(_:))
        case .touchUpInside:
            return #selector(eventTouchUpInside(_:))
        case .touchUpOutside:
            return #selector(eventTouchUpOutside(_:))
        case .touchCancel:
            return #selector(eventTouchCancel(_:))
        case .valueChanged:
            return #selector(eventValueChanged(_:))
        case .primaryActionTriggered:
            return #selector(eventPrimaryActionTriggered(_:))
        case .editingDidBegin:
            return #selector(eventEditingDidBegin(_:))
        case .editingChanged:
            return #selector(eventEditingChanged(_:))
        case .editingDidEnd:
            return #selector(eventEditingDidEnd(_:))
        case .editingDidEndOnExit:
            return #selector(eventEditingDidEndOnExit(_:))
        case .allTouchEvents:
            return #selector(eventAllTouchEvents(_:))
        case .allEditingEvents:
            return #selector(eventAllEditingEvents(_:))
        case .applicationReserved:
            return #selector(eventApplicationReserved(_:))
        case .systemReserved:
            return #selector(eventSystemReserved(_:))
        default: return #selector(eventAllEvents(_:))
        }
    }
}
#endif
