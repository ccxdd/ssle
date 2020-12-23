//
//  UIScrollView+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/11/5.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIScrollView {
    var headerRefreshCtrl: RefreshControl? {
        get {
            return objc_getAssociatedObject(self, &HeaderRefreshKey) as? RefreshControl
        }
        set {
            objc_setAssociatedObject(self, &HeaderRefreshKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var footerRefreshCtrl: RefreshControl? {
        get {
            return objc_getAssociatedObject(self, &FooterRefreshKey) as? RefreshControl
        }
        set {
            objc_setAssociatedObject(self, &FooterRefreshKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func headerRefresh(style: RefreshControl.Style, closure: @escaping () -> Void) {
        if headerRefreshCtrl != nil {
            headerRefreshCtrl?.callback = closure
            return
        }
        headerRefreshCtrl?.removeFromSuperview()
        headerRefreshCtrl = nil
        let ctrl: RefreshControl
        
        switch style {
        case .xib(let type):
            ctrl = type.fromNib()
        case let .custom(c):
            ctrl = c as! RefreshControl
        }
        addSubview(ctrl)
        ctrl.vc = UIViewController.currentVC
        ctrl.mwl.t(-ctrl.ctrlHeight).midX().w(anchor: widthAnchor).h(ctrl.ctrlHeight)
        //ctrl.frame = CGRect(x: frame.origin.x, y: frame.origin.y - ctrl.ctrlHeight, width: frame.width, height: ctrl.ctrlHeight)
        alwaysBounceVertical = true
        headerRefreshCtrl = ctrl
        headerRefreshCtrl?.callback = closure
    }
    
    func footerRefresh(style: RefreshControl.Style, closure: @escaping () -> Void) {
        if footerRefreshCtrl != nil {
            footerRefreshCtrl?.callback = closure
            return
        }
        footerRefreshCtrl?.removeFromSuperview()
        footerRefreshCtrl = nil
        let ctrl: RefreshControl
        
        switch style {
        case .xib(let type):
            ctrl = type.fromNib()
        case let .custom(c):
            ctrl = c as! RefreshControl
        }
        addSubview(ctrl)
        ctrl.type = .footer
        ctrl.mwl.b(ctrl.ctrlHeight).midX().w(anchor: widthAnchor).h(ctrl.ctrlHeight)
        ctrl.isHidden = true
        alwaysBounceVertical = true
        footerRefreshCtrl = ctrl
        footerRefreshCtrl?.callback = closure
    }
    
    func startHeaderRefresh(_ mode: RefreshControl.Mode = .always) {
        switch mode {
        case .always: break
        case .empty:
            if isEmpty == false { return }
        case let .condition(need):
            if need == false { return }
        }
        guard let refreshCtrl = headerRefreshCtrl, refreshCtrl.status != .refreshing else { return }
        refreshCtrl.status = .refreshing
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.contentInset.top = refreshCtrl.ctrlHeight
            if refreshCtrl.firstLoad == false {
                self?.contentOffset.y += -refreshCtrl.ctrlHeight
            }
        }, completion: { (end) in
            refreshCtrl.callback?()
            refreshCtrl.firstLoad = false
        })
    }
    
    func endHeaderRefresh(reloadEmptyStyle: Bool = true) {
        guard let refreshCtrl = headerRefreshCtrl, refreshCtrl.status != .normal else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
            endAnimation()
        }
        func endAnimation() {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.contentInset.top = 0
            }, completion: { [weak self] (end) in
                refreshCtrl.status = .normal
                self?.contentInset.top = 0
                if reloadEmptyStyle {
                    self?.asTo(UICollectionView.self)?.reloadDataEmptyStyle()
                }
            })
        }
    }
    
    func startFooterRefresh() {
        guard let refreshCtrl = footerRefreshCtrl, refreshCtrl.status != .refreshing else { return }
        refreshCtrl.status = .prepare
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentInset.bottom = refreshCtrl.ctrlHeight
        }
    }
    
    func endFooterRefresh() {
        guard let refreshCtrl = footerRefreshCtrl, refreshCtrl.status != .normal else { return }
        refreshCtrl.status = .normal
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentInset.bottom = 0
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case let scrollView as UITableView:
            return scrollView.totalCount() == 0
        case let scrollView as UICollectionView:
            return scrollView.totalCount == 0
        default: return true
        }
    }
    
    func showIndicator(v: Bool, h: Bool) {
        showsVerticalScrollIndicator = v
        showsHorizontalScrollIndicator = h
    }
}


private var HeaderRefreshKey: Void?
private var FooterRefreshKey: Void?

public protocol RefreshControlDelegate {
    var ctrlHeight: CGFloat { get }
    func normal()
    func prepare()
    func refreshing()
}

extension RefreshControl: RefreshControlDelegate {
    @objc open var ctrlHeight: CGFloat {
        return 0
    }
    @objc open func normal() {}
    @objc open func prepare() {}
    @objc open func refreshing() {}
}

open class RefreshControl: UIView {
    public enum Status {
        case normal, prepare, refreshing
    }
    
    public enum Category {
        case header, footer
    }
    
    public enum Mode {
        case empty, always, condition(Bool)
    }
    
    public enum Style {
        case xib(RefreshControl.Type)
        case custom(RefreshControlDelegate)
    }
    
    public weak var scrollView: UIScrollView!
    fileprivate var type: RefreshControl.Category = .header
    fileprivate weak var vc: UIViewController?
    fileprivate var firstLoad: Bool = true
    fileprivate var callback: (() -> Void)?
    
    public var status = RefreshControl.Status.normal {
        willSet {
            switch newValue {
            case .normal:
                normal()
            case .prepare:
                prepare()
            case .refreshing:
                refreshing()
            }
        }
    }
    
    public var isRefreshing: Bool {
        return status == .refreshing
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, (keyPath == #keyPath(UIScrollView.contentOffset) || keyPath == #keyPath(UIScrollView.contentSize)) else {
            return
        }
        
        switch keyPath {
        case #keyPath(UIScrollView.contentOffset):
            guard let offset = change?[.newKey] as? CGPoint, status != .refreshing, isHidden == false else { return }
            switch (type, scrollView.isDragging, status) {
            case (.header, true, _):
                if offset.y < -(ctrlHeight + navBarHeight()) {
                    status = .prepare
                } else {
                    status = .normal
                }
            case (.header, false, .prepare):
                status = .refreshing
                scrollView.contentInset.top = ctrlHeight
                callback?()
            case (.footer, true, _):
                switch scrollView.contentSize.height > scrollView.frame.height {
                case true:
                    if offset.y + scrollView.frame.height > scrollView.contentSize.height + ctrlHeight {
                        status = .prepare
                    } else {
                        status = .normal
                    }
                case false:
                    if offset.y >= 0  {
                        status = .prepare
                    } else {
                        status = .normal
                    }
                }
            case (.footer, false, .prepare):
                status = .refreshing
                scrollView.contentInset.bottom = ctrlHeight
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.callback?()
                }
            default: break
            }
        default:
            if let contentSize = change?[.newKey] as? CGSize, type == .footer {
                frame.origin.y = contentSize.height
            }
        }
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.superview?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
            self.superview?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        } else {
            newSuperview?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
            newSuperview?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
            scrollView = newSuperview as? UIScrollView
        }
    }
    
    func navBarHeight() -> CGFloat {
        if vc?.navigationController != nil {
            return SCR.navigationBarHeight
        }
        return 0
    }
}
#endif
