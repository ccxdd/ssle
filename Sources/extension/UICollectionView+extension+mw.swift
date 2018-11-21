//
//  UICollectionView+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 16/5/26.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

//MARK: - DataManager -

public enum OffsetDirection {
    case none ,up, down, left, right
}

private class DataManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var sectionDict: [Int:CollectionViewSectionManager] = [0:CollectionViewSectionManager()]
    var currentSection: Int = 0 {
        willSet {
            if sectionDict[newValue] == nil {
                sectionDict[newValue] = CollectionViewSectionManager()
                sectionDict[newValue]?.section = newValue
            }
        }
    }
    var currentSectionManager: CollectionViewSectionManager {
        get {
            return sectionDict[currentSection]!
        }
        set {
            sectionDict[currentSection] = newValue
        }
    }
    
    var selectedAtIndexPath: SelectedAtIndexPathClosure?
    var willDisplayIndexPathClosure: cellAtIndexPathClosure?
    var endDisplayIndexPathClosure: cellAtIndexPathClosure?
    var didScroll: ((_ indexPath: IndexPath?, _ contentOffset: CGPoint) -> Void)?
    var didEndDecelerating: ((_ indexPath: IndexPath?, _ item: Any?) -> Void)?
    var didEndDragging: ((_ decelerate: Bool, _ direction: OffsetDirection, _ offsets: [CGPoint]) -> Void)?
    // banner
    fileprivate var isCircle: Bool = false
    fileprivate var timer: GCDTimer?
    fileprivate var direction: UICollectionView.ScrollDirection = .horizontal
    var scrollInterval: CGFloat = 0
    var currPageIndex: Int = 0
    var scrollCacheMultiple: Int = 1
    var display: Int = 1
    var factCount: Int {
        return sectionDict[0]!.sectionData.count / scrollCacheMultiple
    }
    fileprivate var changeIdxClosure: ((Int) -> Void)?
    fileprivate weak var collectionView: UICollectionView?
    // start end offset
    fileprivate var startOffset: CGPoint = CGPoint.zero
    fileprivate var endOffset: CGPoint = CGPoint.zero
    fileprivate var offsetDirection: OffsetDirection {
        switch (startOffset, endOffset) {
        case let (s, e) where s == e:
            return .none
        case let (s, e) where s.x == e.x:
            return s.y > e.y ? .down : .up
        case let (s, e) where s.y == e.y:
            return s.x > e.x ? .left : .right
        default: return .none
        }
    }
    fileprivate var dataEmptyStyle: UICollectionView.DataEmptyStyle = .none
    var selectedIndexPathReload: Bool = false
    var selectedIndexPath: IndexPath?
    
    // MARK: - UICollectionViewDataSource -
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = sectionDict[section]?.rowsInSection ?? 0
        return rows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = ""
        let cellSetting = sectionDict[indexPath.section]!.cellSetting
        if let aClass = cellSetting.className {
            identifier = String(describing: aClass) + (cellSetting.identifierUnique ? "\(indexPath.section)\(indexPath.row)" : "")
            if cellSetting.identifierUnique {
                collectionView.registerColl(aClass, category: cellSetting.category, id: identifier)
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        let item = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
        (cell as? RowItemProtocol)?.setCellItem(item: item, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var identifier = ""
        let isHeader = kind == UICollectionView.elementKindSectionHeader
        let sectionMG = sectionDict[indexPath.section]
        if let cls = isHeader ? sectionMG?.headerSetting.className : sectionMG?.footerSetting.className {
            identifier = String(describing: cls)
        }
        
        let suppleView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        let item = isHeader ? sectionMG?.headerSetting.item : sectionMG?.footerSetting.item
        (suppleView as? SectionItemProtocol)?.setViewItem(item: item, section: indexPath.section)
        
        return suppleView
    }
    
    // MARK: - UICollectionViewDelegate -
    
    fileprivate func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
        selectedAtIndexPath?(indexPath, item)
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        if selectedIndexPathReload {
            collectionView.reloadData()
        }
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
        willDisplayIndexPathClosure?(indexPath, item, cell)
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let isHeader = elementKind == UICollectionView.elementKindSectionHeader
        let item = isHeader ? sectionDict[indexPath.section]?.headerSetting.item : sectionDict[indexPath.section]?.footerSetting.item
        willDisplayIndexPathClosure?(indexPath, item, view as! UICollectionViewCell)
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
        endDisplayIndexPathClosure?(indexPath, item, cell)
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        let isHeader = elementKind == UICollectionView.elementKindSectionHeader
        let item = isHeader ? sectionDict[indexPath.section]?.headerSetting.item : sectionDict[indexPath.section]?.footerSetting.item
        endDisplayIndexPathClosure?(indexPath, item, view as! UICollectionViewCell)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout -
    
    fileprivate func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let setting = sectionDict[indexPath.section]?.cellSetting, setting.size != .zero else { return CGSize.zero}
        return calcSectionAndRowSize(setting: setting, indexPath: indexPath)
    }
    
    fileprivate func calcSectionAndRowSize(setting: SectionAndRowSetting, indexPath: IndexPath, isSection: Bool = false) -> CGSize {
        
        guard let aClass = setting.className, setting.autoSizeCondition.count > 0 else { return setting.size }
        guard let cell = UIView.xib(aClass) else { return setting.size }
        
        var w_priority = UILayoutPriority.required
        var h_priority = UILayoutPriority.fittingSizeLevel
        var minH: CGFloat = 0
        var minW: CGFloat = 0
        var maxH: CGFloat = 0
        var maxW: CGFloat = 0
        var paddingW: CGFloat = 0
        var paddingH: CGFloat = 0
        let item = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
        for auto in setting.autoSizeCondition {
            switch auto {
            case .autoH:
                h_priority = UILayoutPriority.fittingSizeLevel
            case .autoW:
                w_priority = UILayoutPriority.fittingSizeLevel
            case .requiredH:
                h_priority = UILayoutPriority.required
            case .requiredW:
                w_priority = UILayoutPriority.required
            case .minH(let v):
                minH = v
                h_priority = UILayoutPriority.fittingSizeLevel
            case .minW(let v):
                minW = v
                w_priority = UILayoutPriority.fittingSizeLevel
            case .maxH(let v):
                maxH = v
                h_priority = UILayoutPriority.fittingSizeLevel
            case .maxW(let v):
                maxW = v
                w_priority = UILayoutPriority.fittingSizeLevel
            case .assignW(let c):
                return CGSize(width: c(item, indexPath), height: setting.size.height)
            case .assignH(let c):
                return CGSize(width: setting.size.width, height: c(item, indexPath))
            case .paddingW(let f):
                paddingW = f
            case .paddingH(let f):
                paddingH = f
            }
        }
        if isSection {
            (cell as? SectionItemProtocol)?.setViewItem(item: setting.item, section: indexPath.section)
        } else {
            (cell as? RowItemProtocol)?.setCellItem(item: item, indexPath: indexPath)
        }
        cell.frame.size = setting.size
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let newSize = cell.systemLayoutSizeFitting(setting.size, withHorizontalFittingPriority: w_priority, verticalFittingPriority: h_priority)
        maxW = maxW == 0 ? max(newSize.width, minW) : maxW
        maxH = maxH == 0 ? max(newSize.height, minH) : maxH
        let width = min(max(newSize.width, minW), maxW) + paddingW * 2
        let height = min(max(newSize.height, minH), maxH) + paddingH * 2
        let size = CGSize(width: width, height: height)
        return size
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let setting = sectionDict[section]?.headerSetting, setting.size != .zero {
            return calcSectionAndRowSize(setting: setting, indexPath: IndexPath(item: 0, section: section), isSection: true)
        }
        return CGSize.zero
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let setting = sectionDict[section]?.footerSetting, setting.size != .zero {
            return calcSectionAndRowSize(setting: setting, indexPath: IndexPath(item: 0, section: section), isSection: true)
        }
        return CGSize.zero
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let lineSpacing = sectionDict[section]?.minimumLineSpacing ?? 0
        return lineSpacing
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let interitemSpacing = sectionDict[section]?.minimumInteritemSpacing ?? 0
        return interitemSpacing
    }
    
    fileprivate func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = sectionDict[section]?.insets ?? UIEdgeInsets.zero
        return insets
    }
    
    // MARK: - UIScrollViewDelegate -
    
    fileprivate func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = collectionView?.indexPathForItem(at: scrollView.contentOffset)
        didScroll?(indexPath, scrollView.contentOffset)
        // banner
        guard isCircle, let count = sectionDict[0]?.sectionData.count, count > 1, collectionView?.isDragging == true else { return }
        let offsetX = scrollView.contentOffset.x
        switch offsetX {
        case let x where x > CGFloat(count - 1) * scrollView.frame.width:
            (scrollView as? UICollectionView)?.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
        case let x where x < scrollView.frame.width:
            (scrollView as? UICollectionView)?.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .left, animated: false)
        default: break
        }
    }
    
    fileprivate func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollInterval > 0 {
            timer?.stop()
        }
        startOffset = scrollView.contentOffset
    }
    
    fileprivate func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPath = collectionView?.indexPathForItem(at: scrollView.contentOffset)
        didEndDecelerating?(indexPath, scrollView.contentOffset)
        guard indexPath != nil else { return }
        currPageIndex = indexPath!.row
        if scrollInterval > 0 {
            timer?.start()
        }
        changeIdxClosure?(currPageIndex % factCount)
    }
    
    fileprivate func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        endOffset = scrollView.contentOffset
        didEndDragging?(decelerate, offsetDirection, [startOffset, endOffset])
    }
    
    fileprivate func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                               targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    // MARK: - Banner Mode -
    
    func goToCurrentBanner() {
        guard let maxCount = sectionDict[0]?.sectionData.count else { return }
        let scrollDirection: UICollectionView.ScrollPosition = direction == .horizontal ? .left : .top
        switch isCircle {
        case true:
            switch currPageIndex {
            case let i where i == maxCount - 2 - display:
                let location = i % factCount
                collectionView?.scrollToItem(at: IndexPath(row: location, section: 0), at:  scrollDirection, animated: false)
                collectionView?.scrollToItem(at: IndexPath(row: location + 1, section: 0), at: scrollDirection, animated: true)
                currPageIndex = location + 1
            case let i where i < maxCount - 1:
                collectionView?.scrollToItem(at: IndexPath(row: i + 1, section: 0), at: scrollDirection, animated: true)
                currPageIndex = i + 1
            default: break
            }
        case false:
            if currPageIndex < maxCount - 1 {
                collectionView?.scrollToItem(at: IndexPath(row: currPageIndex + 1, section: 0), at: scrollDirection, animated: true)
                currPageIndex = currPageIndex + 1
            } else {
                collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: scrollDirection, animated: true)
                currPageIndex = 0
            }
        }
        //print(currPageIndex, currPageIndex % factCount)
        changeIdxClosure?(currPageIndex % factCount)
    }
    
    func timerCreate() {
        timer?.cancel()
        timer = GCDTimer(interval: .milliseconds(Int(scrollInterval * 1000)), delay: .milliseconds(Int(scrollInterval * 1000)), type: .repeats) { [weak self] (_) in
            self?.goToCurrentBanner()
        }
    }
}

private var DataManagerKey: Void?

//MARK: - UICollectionView -

public extension UICollectionView {
    fileprivate var dm: DataManager {
        if let dm = objc_getAssociatedObject(self, &DataManagerKey) as? DataManager {
            return dm
        } else {
            let dm = DataManager()
            dataSource = dm
            delegate = dm
            dm.collectionView = self
            objc_setAssociatedObject(self, &DataManagerKey, dm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return dm
        }
    }
    
    public var flowLayout : UICollectionViewFlowLayout? {
        return collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    public var rowsInSection: Int {
        return dm.currentSectionManager.rowsInSection
    }
    
    public var totalCount: Int {
        var result = 0
        for (_, v) in dm.sectionDict {
            result += v.rowsInSection
        }
        return result
    }
    
    public var selectedIndexPath: IndexPath? {
        get {
            return dm.selectedIndexPath
        }
        set {
            dm.selectedIndexPath = newValue
        }
    }
    
    public var timer: GCDTimer? {
        return dm.timer
    }
    
    public func registerColl(_ collectionViewCell:UICollectionViewCell.Type, category: RegisterCategory, id: String? = nil) -> () {
        let identifier = id ?? String(describing: collectionViewCell)
        let cellName = String(describing: collectionViewCell)
        switch category {
        case .nib:
            let nib = UINib(nibName: cellName, bundle: nil)
            register(nib, forCellWithReuseIdentifier: identifier)
        case .code:
            register(collectionViewCell, forCellWithReuseIdentifier: identifier)
        case .onVC: break
        }
    }
    
    public func registerHeader(_ headerClass:UICollectionViewCell.Type, category: RegisterCategory) -> () {
        let identifier = String(describing: headerClass)
        switch category {
        case .nib:
            let nib = UINib(nibName: identifier, bundle: nil)
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
        case .code:
            register(headerClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
        case .onVC: break
        }
    }
    
    public func registerFooter(_ footerClass:UICollectionViewCell.Type, category: RegisterCategory) -> () {
        let identifier = String(describing: footerClass)
        switch category {
        case .nib:
            let nib = UINib(nibName: identifier, bundle: nil)
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
        case .code:
            register(footerClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
        case .onVC: break
        }
    }
    
    @discardableResult
    public func cell(_ collectionViewCell:UICollectionViewCell.Type, category: RegisterCategory = .nib, section: Int? = nil, unique: Bool = false) -> Self {
        registerColl(collectionViewCell, category: category)
        if let s = section, s >= 0 {
            dm.currentSection = s
        }
        dm.currentSectionManager.cellSetting.className = collectionViewCell
        dm.currentSectionManager.cellSetting.category = category
        dm.currentSectionManager.cellSetting.identifierUnique = unique
        return self
    }
    
    @discardableResult
    public func cellSize(w: @autoclosure () -> CGFloat = SCR.W, h: @autoclosure () -> CGFloat = 45, column: Int = 1, auto: [AutoSize] = []) -> Self {
        let inset = dm.currentSectionManager.insets
        let nw = w() - inset.left - inset.right - dm.currentSectionManager.minimumInteritemSpacing * (column - 1).tCGF
        dm.currentSectionManager.cellSetting.size = CGSize(width: nw / CGFloat(column), height: h())
        dm.currentSectionManager.cellSetting.autoSizeCondition = auto
        return self
    }
    
    @discardableResult
    public func section(_ section: Int) -> Self {
        dm.currentSection = section
        return self
    }
    
    @discardableResult
    public func replace(indexPath: IndexPath, with item: Any, reload: Bool = false) -> Self {
        var newSectionData = section(indexPath.section).rowsData()
        newSectionData.remove(at: indexPath.row)
        newSectionData.insert(item, at: indexPath.row)
        dm.currentSectionManager.sectionData = newSectionData
        if reload {
            reloadItems(at: [indexPath])
        }
        return self
    }
    
    @discardableResult
    public func replace(row: Int, with item: Any, reload: Bool = false) -> Self {
        return replace(indexPath: IndexPath(row: row, section: dm.currentSection), with: item, reload: reload)
    }
    
    @discardableResult
    public func header(_ headerClass:UICollectionViewCell.Type, category: RegisterCategory = .nib, section: Int? = nil, reusable: Bool = false) -> Self {
        registerHeader(headerClass, category: category)
        if let s = section, s >= 0 {
            dm.currentSection = s
        }
        dm.currentSectionManager.headerSetting.className = headerClass
        dm.currentSectionManager.headerSetting.category = category
        dm.currentSectionManager.headerSetting.isReusable = reusable
        return self
    }
    
    @discardableResult
    public func headerSize(w: CGFloat = SCR.W, h: CGFloat = 45, auto: [AutoSize] = []) -> Self {
        dm.currentSectionManager.headerSetting.size = CGSize(width: w, height: h)
        dm.currentSectionManager.headerSetting.autoSizeCondition = auto
        return self
    }
    
    @discardableResult
    public func headerItem(_ item: Any?, reload: Bool = false) -> Self {
        dm.currentSectionManager.headerSetting.item = item
        if reload {
            reloadSections(IndexSet(integer: dm.currentSection))
        }
        return self
    }
    
    @discardableResult
    public func footer(_ footerClass:UICollectionViewCell.Type, category: RegisterCategory = .nib, section: Int? = nil, reusable: Bool = false) -> Self {
        registerFooter(footerClass, category: category)
        if let s = section, s >= 0 {
            dm.currentSection = s
        }
        dm.currentSectionManager.footerSetting.className = footerClass
        dm.currentSectionManager.footerSetting.category = category
        dm.currentSectionManager.footerSetting.isReusable = reusable
        return self
    }
    
    @discardableResult
    public func footerSize(w: CGFloat = SCR.W, h: CGFloat = 45, auto: [AutoSize] = []) -> Self {
        dm.currentSectionManager.footerSetting.size = CGSize(width: w, height: h)
        dm.currentSectionManager.footerSetting.autoSizeCondition = auto
        return self
    }
    
    @discardableResult
    public func footerItem(_ item:Any?, reload: Bool = false) -> Self {
        dm.currentSectionManager.footerSetting.item = item
        if reload {
            reloadSections(IndexSet(integer: dm.currentSection))
        }
        return self
    }
    
    @discardableResult
    public func rows(_ rows: Int? = nil) -> Self {
        guard let r = rows else {
            dm.currentSectionManager.rowsInSection = dm.currentSectionManager.sectionData.count
            return self
        }
        dm.currentSectionManager.rowsInSection = r
        return self
    }
    
    @discardableResult
    public func insets(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) -> Self {
        dm.currentSectionManager.insets = UIEdgeInsets(top: t, left: l, bottom: b, right: r)
        return self
    }
    
    @discardableResult
    public func lineGap(line: CGFloat = 0, interitem: CGFloat = 0) -> Self {
        dm.currentSectionManager.minimumLineSpacing = line
        dm.currentSectionManager.minimumInteritemSpacing = interitem
        return self
    }
    
    @discardableResult
    public func sectionData(_ data: [Any]?, append: Bool = false, reload: Bool = false) -> Self {
        guard let sectionData = data else {
            dm.currentSectionManager.rowsInSection = 0
            return self
        }
        var sourceData = dm.currentSectionManager.sectionData
        if append {
            sourceData.append(contentsOf: sectionData)
        } else {
            sourceData = sectionData
        }
        dm.currentSectionManager.sectionData = sourceData
        dm.currentSectionManager.rowsInSection = sourceData.count
        if reload {
            reloadSections(IndexSet(integer: dm.currentSection))
        }
        return self
    }
    
    @discardableResult
    public func reusableSection<T>(data: [T]?, subData: (T) -> [Any], append: Bool = false, reload: Bool = false) -> Self {
        guard let sectionsData = data else {
            dm.currentSectionManager.rowsInSection = 0
            return self
        }
        let section = dm.currentSection
        let reusableSectionMgr = dm.currentSectionManager
        for (i, item) in sectionsData.enumerated() {
            let sectionData = subData(item)
            var newSMgr = reusableSectionMgr
            newSMgr.sectionData = sectionData
            newSMgr.rowsInSection = sectionData.count
            if newSMgr.headerSetting.isReusable {
                newSMgr.headerSetting.item = item
            } else {
                newSMgr.headerSetting = SectionAndRowSetting()
            }
            if newSMgr.footerSetting.isReusable {
                newSMgr.footerSetting.item = item
            } else {
                newSMgr.footerSetting = SectionAndRowSetting()
            }
            dm.currentSection = section + i
            dm.currentSectionManager = newSMgr
        }
        if reload {
            reloadData()
        }
        return self
    }
    
    public func rowsData() -> [Any] {
        return dm.currentSectionManager.sectionData
    }
    
    @discardableResult
    public func copySection(form: Int = 0, to: Int, cell: Bool = true, header: Bool = true, footer: Bool = true) -> Self {
        let form = dm.sectionDict[form]
        dm.sectionDict[to] = form
        dm.currentSection = to
        if cell == false {
            dm.sectionDict[to]?.cellSetting = SectionAndRowSetting()
        }
        if header == false {
            dm.sectionDict[to]?.headerSetting = SectionAndRowSetting()
        }
        if footer == false {
            dm.sectionDict[to]?.footerSetting = SectionAndRowSetting()
        }
        return self;
    }
    
    @discardableResult
    public func reload<T>(_ data: [T]?, completion: NoParamClosure? = nil) -> Self {
        guard let tableData = data, tableData.isEmpty == false else {
            clearData()
            return self;
        }
        dm.sectionDict[0]?.sectionData = tableData
        dm.sectionDict[0]?.rowsInSection = tableData.count
        UIView.animate(withDuration: 0, animations: { [weak self] in
            self?.reloadData()
        }) { (_) in
            completion?()
        }
        return self;
    }
    
    public func reloadSection(_ section: Int? = nil) {
        guard let s = section else {
            reloadSections(IndexSet(integer: dm.currentSection))
            return
        }
        reloadSections(IndexSet(integer: s))
    }
    
    public func clearData(_ reload: Bool = true) {
        for (k, _) in dm.sectionDict {
            dm.sectionDict[k]?.sectionData.removeAll()
            dm.sectionDict[k]?.rowsInSection = 0
        }
        if reload {
            reloadData()
        }
        dm.currentSection = 0
    }
    
    public func selectedAtIndexPath(_ closure: SelectedAtIndexPathClosure?) {
        dm.selectedAtIndexPath = closure
    }
    
    public func willDisplayIndexPath(_ closure: cellAtIndexPathClosure?) {
        dm.willDisplayIndexPathClosure = closure
    }
    
    public func endDisplayIndexPath(_ closure: cellAtIndexPathClosure?) {
        dm.endDisplayIndexPathClosure = closure
    }
    
    public func didScroll(_ closure:((_ indexPath: IndexPath?, _ contentOffset: CGPoint) -> Void)?) {
        dm.didScroll = closure
    }
    
    public func didEndDecelerating(_ closure:((_ indexPath: IndexPath?, _ item: Any?) -> Void)?) {
        dm.didEndDecelerating = closure
    }
    
    public func didEndDragging(_ closure: ((_ decelerate: Bool, _ direction: OffsetDirection, _ offsets: [CGPoint]) -> Void)?) {
        dm.didEndDragging = closure
    }
    
    public func removeSection(_ section: Int) {
        dm.sectionDict.removeValue(forKey: section)
        if section == 0 {
            dm.sectionDict[0] = CollectionViewSectionManager()
            dm.currentSection = 0
        }
    }
    
    public func removeAllSections() {
        dm.sectionDict.removeAll()
        dm.sectionDict[0] = CollectionViewSectionManager()
        dm.currentSection = 0
    }
    
    public func bannerMode<T>(data: [T], interval: CGFloat = 5, circle: Bool = true, multiple: Int = 5, display: Int = 1, change: ((Int) -> Void)? = nil) {
        guard data.count > 0 else { return }
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        guard data.count > 1, circle else {
            reload(data)
            return
        }
        var repeatData: [T] = []
        for _ in 0..<multiple {
            repeatData.append(contentsOf: data)
        }
        reload(repeatData)
        dm.isCircle = circle
        dm.scrollCacheMultiple = multiple
        dm.display = display
        dm.changeIdxClosure = change
        dm.scrollInterval = interval < 0.4 ? 0.4 : interval
        dm.direction = flowLayout?.scrollDirection ?? .horizontal
        DispatchQueue.main.async { [weak self] in
            self?.dm.currPageIndex = multiple / 2 * data.count
            self?.scrollToItem(at: IndexPath(item: self!.dm.currPageIndex, section: 0), at: self?.dm.direction == .horizontal ? .left : .top, animated: false)
            self?.dm.timerCreate()
            self?.bannerStart()
        }
    }
    
    public func bannerStop() {
        dm.timer?.stop()
    }
    
    public func bannerStart() {
        guard section(0).rowsData().count > 0 else { return }
        dm.timer?.start()
    }
    
    public func headerAt(_ section: Int = 0) -> UICollectionReusableView? {
        return supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: section))
    }
    
    public func footerAt(_ section: Int) -> UICollectionReusableView? {
        return supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: section))
    }
    
    public func pointWithIdx(_ idx: Int, position: UICollectionView.ScrollPosition = .centeredHorizontally) -> CGPoint {
        guard let cell = cellForItem(at: idx.row()) else { return CGPoint.zero }
        let w = cell.frame.width
        let x1 = cell.frame.minX
        let surplusOffset = contentSize.width - frame.width - contentOffset.x
        let scrX = convert(x1.pointY(), to: nil).x
        let centerOffsetX = ((frame.width - w) / 2) - scrX
        //print(centerOffsetX, surplusOffset, contentOffset.x, scrX)
        switch (centerOffsetX >= 0, abs(centerOffsetX) <= surplusOffset, centerOffsetX <= contentOffset.x) {
        case (true, _, true), (false, true, _):  //左移、右移，距离够
            return ((frame.width - w) / 2).pointX()
        case (true, _, false): //右移，不够
            return (scrX + contentOffset.x).pointX()
        case (false, false, _)://左移，不够
            if contentSize.width <= frame.width {
                return x1.pointX()
            } else {
                return (scrX - surplusOffset).pointX()
            }
        }
    }
    
    @discardableResult
    public func selectedIndexPath(reload: Bool) -> Self {
        dm.selectedIndexPathReload = reload
        return self
    }
    
    @discardableResult
    public func indexPath<T: UICollectionViewCell>(_ idxP: IndexPath, class: T.Type) -> T? {
        return cellForItem(at: idxP) as? T
    }
}

private var CursorKey: Void?

extension UICollectionView {
    public enum DataEmptyStyle {
        case none
        case image(UIImage)
        case view(UIView)
        case text(title: String, color: UIColor, font: UIFont)
    }
    
    /// cursor
    @IBOutlet weak var cursor: UIView? {
        set {
            objc_setAssociatedObject(self, &CursorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &CursorKey) as? UIView
        }
    }
    
    public var dataEmptyStyle: DataEmptyStyle {
        set {
            dm.dataEmptyStyle = newValue
        }
        get {
            return dm.dataEmptyStyle
        }
    }
    
    public func reloadDataEmptyStyle() {
        guard totalCount == 0 else {
            backgroundView = nil
            return
        }
        switch dm.dataEmptyStyle {
        case .none:
            backgroundView = nil
        case .image(let img):
            let imageView = UIImageView(image: img)
            imageView.contentMode = .center
            backgroundView = imageView
        case .view(let v):
            backgroundView = v
        case let .text(title: t, color: c, font: f):
            let lab = UILabel()
            lab.text = t
            lab.font = f
            lab.textColor = c
            lab.textAlignment = .center
            backgroundView = lab
        }
    }
    
    static public func initLayout(_ frame: CGRect = .zero, _ direction: UICollectionView.ScrollDirection = .vertical) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        let collView = UICollectionView(frame: frame, collectionViewLayout: layout)
        return collView
    }
}

public typealias delClosure = (Bool) -> Void
public typealias SelectedAtIndexPathClosure = (IndexPath, Any?) -> Void
public typealias DeletedAtIndexPathClosure = (IndexPath, Any?, @escaping delClosure) -> Void
public typealias cellAtIndexPathClosure = (IndexPath, Any?, UICollectionViewCell) -> Void

public protocol RowItemProtocol {
    func setCellItem(item: Any?, indexPath: IndexPath)
}

public protocol SectionItemProtocol {
    func setViewItem(item: Any?, section: Int)
}

public enum RegisterCategory {
    case nib, code, onVC
}

public enum AutoSize {
    case requiredW
    case requiredH
    case autoW
    case autoH
    case minW(CGFloat)
    case minH(CGFloat)
    case maxW(CGFloat)
    case maxH(CGFloat)
    case assignW((Any?, IndexPath) -> CGFloat)
    case assignH((Any?, IndexPath) -> CGFloat)
    case paddingW(CGFloat)
    case paddingH(CGFloat)
}

private struct SectionAndRowSetting {
    var size = CGSize.zero
    var autoSizeCondition = [AutoSize]()
    var className: UICollectionViewCell.Type?
    var item: Any?
    var category = RegisterCategory.nib
    var isReusable: Bool = false
    var identifierUnique: Bool = false
}

private struct CollectionViewSectionManager {
    var cellSetting = SectionAndRowSetting()
    var headerSetting = SectionAndRowSetting()
    var footerSetting = SectionAndRowSetting()
    var insets = UIEdgeInsets.zero
    var sectionData: [Any] = []
    var section: Int = 0
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    var rowsInSection: Int = 0
}

