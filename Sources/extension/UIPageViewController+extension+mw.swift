//
//  UIPageController+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2017/1/22.
//  Copyright © 2017年 ccxdd. All rights reserved.
//

#if os(iOS)
import UIKit

private var DataManagerKey: Void?

public extension UIPageViewController {
    private var dm: PageViewDataManager {
        guard let dm = objc_getAssociatedObject(self, &DataManagerKey) as? PageViewDataManager else {
            let dm = PageViewDataManager()
            objc_setAssociatedObject(self, &DataManagerKey, dm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return dm
        }
        return dm
    }
    
    var currentIndex: Int {
        set {
            dm.currentIndex = newValue
        }
        get {
            return dm.currentIndex
        }
    }
    
    var maxCount: Int {
        set {
            dm.maxCount = newValue
        }
        get {
            return dm.maxCount
        }
    }
    
    var currentIdxVC: UIViewController? {
        return dm.vcArray.at(currentIndex)
    }
    
    var count: Int {
        return dm.vcArray.count
    }
    
    var vcArray: [UIViewController] {
        return dm.vcArray
    }
    
    @IBOutlet var collectionView: UICollectionView? {
        get {
            return dm.collectionView
        }
        set {
            dm.collectionView = newValue
        }
    }
    
    convenience init(style: UIPageViewController.TransitionStyle = .scroll,
                     orientation: UIPageViewController.NavigationOrientation = .horizontal,
                     data: [UIViewController]) {
        self.init(transitionStyle: style, navigationOrientation: orientation, options: nil)
        guard !data.isEmpty else { return }
        setViewControllers(data)
    }
    
    func setViewControllers(_ data:[UIViewController], showIdx: Int = 0) {
        dm.vcArray = data
        dm.maxCount = data.count
        dm.currentIndex = showIdx
        delegate = dm
        dataSource = dm
        let vc = data.at(showIdx) ?? data.first!
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    func goPage(at: Int, animated: Bool = true) {
        guard let vc = indexVC(at: at) else { return }
        setViewControllers([vc], direction: at > currentIndex ? .forward : .reverse, animated: animated, completion: nil)
        currentIndex = at
        dm.didChangeClosure?(at, vc)
    }
    
    func willChange(_ closure: @escaping (Int, UIViewController) -> Void) {
        dm.willChangeClosure = closure
    }
    
    func didChange(_ closure: @escaping (Int, UIViewController) -> Void) {
        dm.didChangeClosure = closure
    }
    
    func indexVC(at idx: Int) -> UIViewController? {
        return dm.indexVC(at: idx)
    }
    
    func autoCreate(vc: @escaping (Int) -> UIViewController) {
        dataSource = dm
        delegate = dm
        dm.createClosure = vc
    }
}

fileprivate final class PageViewDataManager: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var currentIndex: Int = 0
    var maxCount: Int = 0
    var willChangeClosure: ((Int, UIViewController) -> Void)?
    var didChangeClosure: ((Int, UIViewController) -> Void)?
    var createClosure: ((Int) -> UIViewController)?
    var vcArray: [UIViewController] = []
    var collectionView: UICollectionView?
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let idx = currentIndex
        if idx >= maxCount - 1 {
            return nil
        }
        guard let vc = indexVC(at: idx + 1) else { return nil }
        willChangeClosure?(idx + 1, vc)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let idx = currentIndex
        if idx <= 0 {
            return nil
        }
        guard let vc = indexVC(at: idx - 1) else { return nil }
        willChangeClosure?(idx - 1, vc)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let vc = pageViewController.viewControllers?.first, let idx = vcArray.firstIndex(of: vc) else { return }
        currentIndex = idx
        didChangeClosure?(idx, vc)
        collectionView?.selectedIndexPath = idx.row()
        collectionView?.reloadData()
    }
    
    func indexVC(at idx: Int) -> UIViewController? {
        guard let vc = vcArray.at(idx) else {
            guard let newVC = createClosure?(idx) else { return nil }
            vcArray.append(newVC)
            willChangeClosure?(idx, newVC)
            return newVC
        }
        willChangeClosure?(idx, vc)
        return vc
    }
}
#endif

