//
//  UITableView+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/10/26.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

extension UITableView {
    
    public enum CustomEditingStyle {
        case none, delete, insert, check
    }
    
    fileprivate var dm: DataManager {
        if let dm = objc_getAssociatedObject(self, &TableViewDataManagerKey) as? DataManager {
            return dm
        } else {
            let dm = DataManager()
            dataSource = dm
            delegate = dm
            objc_setAssociatedObject(self, &TableViewDataManagerKey, dm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return dm
        }
    }
    
    public func registerCell(_ cellClass:UITableViewCell.Type, category: RegisterCategory) {
        let identifier = String(describing: cellClass)
        switch category {
        case .nib:
            let nib = UINib(nibName: identifier, bundle: nil)
            register(nib, forCellReuseIdentifier: identifier)
        case .code:
            register(cellClass, forCellReuseIdentifier: identifier)
        case .onVC: break
        }
    }
    
    @discardableResult
    public func header(_ sectionClass: UIView.Type, category: RegisterCategory = .nib, section: Int = -1) -> Self {
        if section >= 0 {
            dm.currentSection = section
        }
        dm.currentSectionManager.headerSetting.className = sectionClass
        dm.currentSectionManager.headerSetting.category = category
        return self
    }
    
    @discardableResult
    public func footer(_ sectionClass: UIView.Type, category: RegisterCategory = .nib, section: Int = -1) -> Self {
        if section >= 0 {
            dm.currentSection = section
        }
        dm.currentSectionManager.footerSetting.className = sectionClass
        dm.currentSectionManager.footerSetting.category = category
        return self
    }
    
    @discardableResult
    public func cell(_ cellClass:UITableViewCell.Type, category: RegisterCategory = .nib, section: Int = -1) -> Self {
        registerCell(cellClass, category: category)
        if section >= 0 {
            dm.currentSection = section
        }
        dm.currentSectionManager.cellSetting.className = cellClass
        dm.currentSectionManager.cellSetting.category = category
        return self
    }
    
    @discardableResult
    public func cellSize(w: CGFloat = SCR.W, h:CGFloat, auto: [AutoSize] = []) -> Self {
        dm.currentSectionManager.cellSetting.size = CGSize(width: w, height: h)
        dm.currentSectionManager.cellSetting.autoSizeCondition = auto
        return self
    }
    
    @discardableResult
    public func section(_ section: Int) -> Self {
        dm.currentSection = section
        return self
    }
    
    @discardableResult
    public func headerSize(w: CGFloat = SCR.W, h:CGFloat, auto: [AutoSize] = []) -> Self {
        dm.currentSectionManager.headerSetting.size = CGSize(width: w, height: h)
        dm.currentSectionManager.headerSetting.autoSizeCondition = auto
        return self
    }
    
    @discardableResult
    public func headerItem(_ item:Any?) -> Self {
        dm.currentSectionManager.headerSetting.item = item
        return self
    }
    
    @discardableResult
    public func footerSize(w: CGFloat = SCR.W, h:CGFloat, auto: [AutoSize] = []) -> Self {
        dm.currentSectionManager.footerSetting.size = CGSize(width: w, height: h)
        dm.currentSectionManager.footerSetting.autoSizeCondition = auto
        return self
    }
    
    @discardableResult
    public func footerItem(_ item:Any?) -> Self {
        dm.currentSectionManager.footerSetting.item = item
        return self
    }
    
    @discardableResult
    public func rows(_ rows: Int, section: Int = -1) -> Self {
        if section >= 0 {
            dm.currentSection = section
        }
        dm.currentSectionManager.rowsInSection = rows
        return self
    }
    
    @discardableResult
    public func allowEditingStyle(_ style: CustomEditingStyle) -> Self {
        dm.editingStyle = style
        return self
    }
    
    @discardableResult
    public func reload(_ data: [Any]?, multipleSections: Bool = false) -> Self {
        guard let tableData = data, tableData.count > 0 else {
            clearData()
            return self;
        }
        switch multipleSections {
        case true:
            var copySM = dm.sectionDict[0]!
            dm.sectionDict.removeAll()
            for (index, item) in tableData.enumerated() {
                if let sectionData = item as? [Any] {
                    copySM.sectionData = sectionData
                    copySM.rowsInSection = sectionData.count
                    dm.sectionDict[index] = copySM
                }
            }
        case false:
            if dm.sectionDict.count == 1 {
                dm.sectionDict[0]?.sectionData = tableData
                dm.sectionDict[0]?.rowsInSection = tableData.count
            }
        }
        reloadData()
        return self
    }
    
    @discardableResult
    public func sectionData(_ data: [Any], append: Bool = false, reload: Bool = false) -> Self {
        var sourceData = dm.currentSectionManager.sectionData
        if append {
            sourceData.append(contentsOf: data)
        } else {
            sourceData = data
        }
        dm.currentSectionManager.sectionData = sourceData
        dm.currentSectionManager.rowsInSection = sourceData.count
        if reload {
            reloadSections(IndexSet(integer: dm.currentSection), with: .automatic)
        }
        return self
    }
    
    public func sectionData() -> [Any] {
        return dm.currentSectionManager.sectionData
    }
    
    public func totalCount() -> Int {
        var result = 0
        for (_, v) in dm.sectionDict {
            result += v.rowsInSection
        }
        return result
    }
    
    public func clearData(_ reload: Bool = true) {
        for (key, _) in dm.sectionDict {
            dm.sectionDict[key]?.sectionData = []
            dm.sectionDict[key]?.rowsInSection = 0
        }
        if reload {
            reloadData()
        }
    }
    
    
    public func selectedAtIndexPath(_ closure:SelectedAtIndexPathClosure?) {
        dm.selectedAtIndexPath = closure
    }
    
    public func deletedAtIndexPath(_ closure:DeletedAtIndexPathClosure?) {
        dm.deletedAtIndexPath = closure
    }
    
    public func didScroll(_ closure:((_ indexPath: IndexPath?, _ contentOffset: CGPoint) -> Void)?) {
        dm.didScroll = closure
    }
    
    public func didEndDecelerating(_ closure:((_ indexPath: IndexPath?, _ item: Any?) -> Void)?) {
        dm.didEndDecelerating = closure
    }
    
    public func resultData() -> [Any] {
        if dm.sectionDict.count > 0 {
            var results = [Any]()
            for (_, mg) in dm.sectionDict {
                if mg.sectionData.count > 0 {
                    results.append(mg.sectionData)
                }
            }
            return results
        } else {
            return dm.sectionDict[0]!.sectionData
        }
    }
    
    public func extensionDelegate(_ obj: (UITableViewDataSource & UITableViewDelegate)?) {
        dm.extensionDelegate = obj
    }
}

//MARK: - DataManager -

private var TableViewDataManagerKey: Void?

private class DataManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var sectionDict: [Int:TableViewSectionManager] = [0:TableViewSectionManager()]
    var currentSection: Int = 0 {
        willSet {
            if sectionDict[newValue] == nil {
                sectionDict[newValue] = TableViewSectionManager()
                sectionDict[newValue]?.section = newValue
            }
        }
    }
    var currentSectionManager: TableViewSectionManager {
        get {
            return sectionDict[currentSection]!
        }
        set {
            sectionDict[currentSection] = newValue
        }
    }
    
    var selectedAtIndexPath: SelectedAtIndexPathClosure?
    var deletedAtIndexPath: DeletedAtIndexPathClosure?
    var didScroll: ((_ indexPath: IndexPath?, _ contentOffset: CGPoint) -> Void)?
    var didEndDecelerating: ((_ indexPath: IndexPath?, _ item: Any?) -> Void)?
    var editingStyle = UITableView.CustomEditingStyle.none
    var extensionDelegate: (UITableViewDelegate & UITableViewDataSource)?
    
    // MARK: - UITableViewDataSource -
    
    fileprivate func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDict.count
    }
    
    fileprivate func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = sectionDict[section]?.rowsInSection ?? 0
        return rows
    }
    
    fileprivate func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = ""
        if let aClass = sectionDict[indexPath.section]?.cellSetting.className {
            identifier = String(describing: aClass)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let item = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
        (cell as? RowItemProtocol)?.setCellItem(item: item, indexPath: indexPath)
        
        return cell
    }
    
    fileprivate func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerClass = sectionDict[section]?.headerSetting.className {
            let header = UIView.xib(headerClass)
            (header as? SectionItemProtocol)?.setViewItem(item: sectionDict[section]?.headerSetting.item, section: section)
            return header
        }
        return nil
    }
    
    fileprivate func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footerClass = sectionDict[section]?.footerSetting.className {
            let footer = UIView.xib(footerClass)
            (footer as? SectionItemProtocol)?.setViewItem(item: sectionDict[section]?.footerSetting.item, section: section)
            return footer
        }
        return nil
    }
    
    // MARK: - UITableViewDelegate -
    
    fileprivate func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
        DispatchQueue.main.async { [weak self] in
            self?.selectedAtIndexPath?(indexPath, item)
        }
    }
    
    fileprivate func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sectionDict[indexPath.section]?.cellSetting.size.height {
        case let h where h! > 0:
            return h!
        default:
            return tableView.rowHeight
        }
    }
    
    fileprivate func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sectionDict[section]?.headerSetting.size.height {
        case let h where h! > 0:
            return h!
        default:
            return tableView.sectionHeaderHeight
        }
    }
    
    fileprivate func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch sectionDict[section]?.footerSetting.size.height {
        case let h where h! > 0:
            return h!
        default:
            return tableView.sectionFooterHeight
        }
    }
    
    fileprivate func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return editingStyle != .none
    }
    
    fileprivate func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let delItem = sectionDict[indexPath.section]?.sectionData.at(indexPath.row)
            deletedAtIndexPath?(indexPath, delItem, { [weak self] result in
                if result {
                    self?.sectionDict[indexPath.section]?.sectionData.remove(at: indexPath.row)
                    self?.sectionDict[indexPath.section]?.rowsInSection -= 1
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
        }
    }
    
    fileprivate func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    fileprivate func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch editingStyle {
        case .none:
            return .none
        case .delete:
            return .delete
        case .insert:
            return .insert
        case .check:
            let style = UITableViewCell.EditingStyle.delete.rawValue | UITableViewCell.EditingStyle.insert.rawValue
            return UITableViewCell.EditingStyle(rawValue: style)!
        }
    }
    
    // MARK: - UIScrollViewDelegate -
    
    fileprivate func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if didScroll != nil {
            let indexPath = (scrollView as! UITableView).indexPathForRow(at: scrollView.contentOffset)
            didScroll!(indexPath, scrollView.contentOffset)
        }
    }
    
    fileprivate func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if didEndDecelerating != nil {
            let indexPath = (scrollView as! UITableView).indexPathForRow(at: scrollView.contentOffset)
            didEndDecelerating!(indexPath, scrollView.contentOffset)
        }
    }
}


private struct SectionAndRowSetting {
    var size = CGSize.zero
    var autoSizeCondition = [AutoSize]()
    var className: UIView.Type?
    var item: Any?
    var category = RegisterCategory.nib
}

private struct TableViewSectionManager {
    var cellSetting = SectionAndRowSetting()
    var headerSetting = SectionAndRowSetting()
    var footerSetting = SectionAndRowSetting()
    var sectionData: [Any] = []
    var section: Int = 0
    var rowsInSection: Int = 0
}

