//
//  UIViewController+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/10/23.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

public extension UIViewController {
    public enum DismissBgType {
        case vc, nav, tab
    }
    
    public enum AddViewType {
        case top, above(UIView), below(UIView)
    }
    
    static public func storyboard(sb: String, identifier: String? = nil, initial: Bool = false) -> UIViewController {
        let vcID = identifier ?? String(describing: self)
        if initial {
            return UIStoryboard(name: sb, bundle: nil).instantiateInitialViewController()!
        }
        return UIStoryboard(name: sb, bundle: nil).instantiateViewController(withIdentifier: vcID)
    }
    
    public static var rootVC: UIViewController? {
        get {
            return UIApplication.shared.windows.first?.rootViewController
        }
        set {
            UIApplication.shared.windows.first?.rootViewController = newValue
        }
    }
    
    public static var currentVC: UIViewController? {
        return rootVC?.topVC()
    }
    
    @discardableResult
    public func find<T: UIViewController>(t: T.Type) -> T? {
        return navigationController?.viewControllers.reversed().filter { $0.isKind(of: t) }.first as? T
    }
    
    public func push(vc: UIViewController?, animated: Bool = true, hidesBottomBar: Bool = true, hidesBackButton: Bool = false, unique: Bool = false) {
        guard let vc = vc else { return }
        if unique && navigationController?.topViewController?.typeOfString == vc.typeOfString {
            print("⚠️ 重复 PUSH ⚠️")
            return
        }
        vc.hidesBottomBarWhenPushed = hidesBottomBar
        vc.navigationItem.hidesBackButton = hidesBackButton
        if #available(iOS 9.0, *) {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    public func present(vc: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let vc = vc else { return }
        present(vc, animated: animated, completion: completion)
    }
    
    public func topVC() -> UIViewController? {
        switch self {
        case is UITabBarController:
            return (self as? UITabBarController)?.selectedViewController?.topVC()
        case is UINavigationController:
            return (self as? UINavigationController)?.visibleViewController?.topVC()
        default:
            return presentedViewController?.topVC() ?? self
        }
    }
    
    public func openDismissBg(type: DismissBgType = .vc, duration: TimeInterval = 0.3, bgColor: UIColor = UIColor.black,
                       alpha: CGFloat = 0.5, addType: AddViewType = .top, endClosure: NoParamClosure? = nil) {
        let backView = UIView()
        backView.alpha = 0
        backView.frame = SCR.B
        backView.backgroundColor = bgColor
        backView.tag = 33455432
        let vc: UIViewController?
        switch type {
        case .vc:
            vc = self
        case .nav:
            vc = navigationController
        default:
            vc = tabBarController
        }
        switch addType {
        case .top:
            vc?.view.addSubview(backView)
        case .above(let v):
            vc?.view.insertSubview(backView, aboveSubview: v)
        case .below(let v):
            vc?.view.insertSubview(backView, belowSubview: v)
        }
        backView.addTap { [weak self] (_) in
            self?.closeDismissBg(type: type, duration: duration, completion: endClosure)
        }
        UIView.animate(withDuration: duration, animations: { 
            backView.alpha = alpha
        }) { (_) in
            
        }
    }
    
    public func closeDismissBg(type: DismissBgType = .vc, duration: TimeInterval = 0.3, completion: NoParamClosure? = nil) {
        let vc: UIViewController?
        switch type {
        case .vc:
            vc = self
        case .nav:
            vc = navigationController
        default:
            vc = tabBarController
        }
        if let view = vc?.view.viewWithTag(33455432) {
            completion?()
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
            })
        }
    }
    
    public func addLeftNavBar(image: UIImage, renderMode: UIImage.RenderingMode = .automatic, click: @escaping (UIBarButtonItem) -> Void) {
        let btn = UIBarButtonItem.init(image: image, style: .plain, target: self,
                                       action: #selector(navBarLeftAction(sender:)))
        btn.cbm.left(t: UIBarButtonItem.self, c: click)
        navigationItem.leftBarButtonItem = btn
    }
    
    public func addLeftNavBar(title: String, click: @escaping (UIBarButtonItem) -> Void) {
        let btn = UIBarButtonItem(title: title, style: .plain, target: self,
                                  action: #selector(navBarLeftAction(sender:)))
        btn.cbm.left(t: UIBarButtonItem.self, c: click)
        navigationItem.leftBarButtonItem = btn
    }
    
    public func addLeftNavBar<T: UIView>(view: T, closure: @escaping GenericsOptionalParamClosure<Any>) {
        let btn = UIBarButtonItem(customView: view)
        view.addTap(closure: closure)
        navigationItem.leftBarButtonItem = btn
    }
    
    public func addRightNavBar(image: UIImage, renderMode: UIImage.RenderingMode = .automatic, click: @escaping (UIBarButtonItem) -> Void) {
        let btn = UIBarButtonItem.init(image: image, style: .plain, target: self,
                                       action: #selector(navBarRightAction(sender:)))
        btn.cbm.right(t: UIBarButtonItem.self, c: click)
        navigationItem.rightBarButtonItem = btn
    }
    
    public func addRightNavBar<T: UIView>(view: T, closure: @escaping GenericsOptionalParamClosure<Any>) {
        let btn = UIBarButtonItem(customView: view)
        view.addTap(closure: closure)
        navigationItem.rightBarButtonItem = btn
    }
    
    public func addRightNavBar(title: String, click: @escaping (UIBarButtonItem) -> Void) {
        let btn = UIBarButtonItem(title: title, style: .plain, target: self,
                                  action: #selector(navBarRightAction(sender:)))
        btn.cbm.right(t: UIBarButtonItem.self, c: click)
        navigationItem.rightBarButtonItem = btn
    }
    
    @objc fileprivate func navBarLeftAction(sender: UIBarButtonItem) {
        sender.cbm.exec(c: .leftNavBtn, p: sender)
    }
    
    @objc fileprivate func navBarRightAction(sender: UIBarButtonItem) {
        sender.cbm.exec(c: .rightNavBtn, p: sender)
    }
    
    public func popVC(_ animated: Bool = true, type: PopVcType? = nil) {
        guard let type = type else {
            _ = navigationController?.popViewController(animated: animated)
            return
        }
        switch type {
        case let .class(c):
            if let vc = self.find(t: c) {
                _ = navigationController?.popToViewController(vc, animated: animated)
            } else {
                _ = navigationController?.popViewController(animated: animated)
            }
        case let .vc(vc):
            _ = navigationController?.popToViewController(vc, animated: animated)
        case let .last(idx):
            guard
                let endIdx = navigationController?.viewControllers.endIndex, endIdx > idx,
                let vc = navigationController?.viewControllers.reversed().at(idx) else {
                _ = navigationController?.popToRootViewController(animated: true)
                return
            }
            _ = navigationController?.popToViewController(vc, animated: animated)
        case let .top(idx):
            guard
                let endIdx = navigationController?.viewControllers.endIndex, endIdx > idx,
                let vc = navigationController?.viewControllers.at(idx) else {
                _ = navigationController?.popToRootViewController(animated: true)
                return
            }
            _ = navigationController?.popToViewController(vc, animated: animated)
        }
    }
    
    @discardableResult
    public func popToRootVC(_ animated: Bool = true) -> [UIViewController]? {
        return self.navigationController?.popToRootViewController(animated: animated)
    }
    
    public func toNav(_ navClass: UINavigationController.Type = UINavigationController.self, modalStyle: UIModalPresentationStyle = .fullScreen) -> UINavigationController {
        let navVC = navClass.init(rootViewController: self)
        navVC.modalPresentationStyle = modalStyle
        return navVC
    }
    
    @IBAction public func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    public func navBar(titleColor: UIColor? = nil, font: UIFont? = nil, tintColor: UIColor? = nil, barColor: UIColor? = nil, transparent: Bool = false) {
        guard let bar = navigationController?.navigationBar else { return }
        var titleAttrs: [NSAttributedString.Key: Any] = [:]
        if let color = titleColor {
            titleAttrs[NSAttributedString.Key.foregroundColor] = color
        }
        if let font = font {
            titleAttrs[NSAttributedString.Key.font] = font
        }
        if !titleAttrs.isEmpty {
            bar.titleTextAttributes = titleAttrs
        }
        switch transparent {
        case true:
            bar.setBackgroundImage(UIImage(), for: .default)
            bar.shadowImage = UIImage()
        default:
            bar.setBackgroundImage(nil, for: .default)
            bar.shadowImage = nil
        }
        bar.barTintColor = barColor ?? bar.barTintColor
        bar.tintColor = tintColor ?? bar.tintColor
        bar.isTranslucent = barColor != nil ? false : true
    }
    
    public func sideMode(sideView: UIView?, w: CGFloat, tabBar: Bool = false, dismissBg: UIColor? = UIColor.black.alpha(0.5)) {
        guard let v = sideView else { return }
        view.viewWithTag(10000001)?.removeFromSuperview()
        view.viewWithTag(10000002)?.removeFromSuperview()
        let statusBarH = SCR.iPhoneX ? SCR.statusBarHeight : 0
        let dismissBtn = UIButton(type: .custom)
        dismissBtn.frame = SCR.B
        dismissBtn.addTarget(self, action: #selector(dismissButtonAction(sender:)), for: .touchUpInside)
        dismissBtn.isHidden = true
        dismissBtn.tag = 10000001
        dismissBtn.backgroundColor = dismissBg
        v.tag = 10000002
        v.frame = CGRect(x: SCR.W(1.1), y: statusBarH, width: w, height: SCR.H - statusBarH - (tabBar ? SCR.tabBarHeight : 0.0))
        view.addSubview(dismissBtn)
        view.addSubview(v)
    }
    
    public func sideOpen(_ isOpen: Bool, duration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        guard let btn = view.viewWithTag(10000001), let sideView = view.viewWithTag(10000002) else { return }
        btn.isHidden = !isOpen
        sideView.isHidden = false
        UIView.animate(withDuration: duration, animations: { 
            sideView.frame.origin.x = isOpen ? SCR.W - sideView.frame.width : SCR.W(1.1)
        }) { (_) in
            completion?(isOpen)
        }
    }
    
    @objc private func dismissButtonAction(sender: UIButton) {
        sideOpen(false)
    }
    
    public func addChild(vc: UIViewController?) {
        guard let v = vc else { return }
        addChild(v)
        v.didMove(toParent: self)
    }
    
    public func removeChild(vc: UIViewController?) {
        vc?.willMove(toParent: nil)
        vc?.removeFromParent()
    }
}

public extension UITabBarController {
    override open var shouldAutorotate: Bool {
        let result = (UIViewController.currentVC as? VCRotateProtocol)?.autoRotate ?? false
        //print("tab", result)
        return result
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let result = (UIViewController.currentVC as? VCRotateProtocol)?.interfaceOrientations ?? [.portrait]
        //print("tab", result)
        return result
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .default
    }
}

public extension UINavigationController {
    override open var shouldAutorotate: Bool {
        let result = (UIViewController.currentVC as? VCRotateProtocol)?.autoRotate ?? false
        //print("nav", result)
        return result
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let result = (UIViewController.currentVC as? VCRotateProtocol)?.interfaceOrientations ?? [.portrait]
        //print("nav", result)
        return result
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}

public protocol VCRotateProtocol {
    var autoRotate: Bool { get }
    var interfaceOrientations: UIInterfaceOrientationMask { get }
}

public extension UICollectionViewController {
    static public func defaultVC() -> Self {
        let layout = UICollectionViewFlowLayout()
        let vc = self.init(collectionViewLayout: layout)
        return vc
    }
}

public extension UITableViewController {
    static public func defaultVC(_ style: UITableView.Style = .plain) -> Self {
        let vc = self.init(style: style)
        return vc
    }
}

public enum PopVcType {
    case `class`(UIViewController.Type)
    case vc(UIViewController)
    case last(Int)
    case top(Int)
}
