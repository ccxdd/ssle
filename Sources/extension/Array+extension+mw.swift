//
//  Array+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/6/01.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import Foundation

extension Array {
    func at(_ index: Int?) -> Element? {
        guard let i = index, i < count, i >= 0 else { return nil }
        return self[i]
    }
    
    func range(from: Int?, to: Int?) -> [Element]? {
        guard let f = from, let t = to, f <= t, f >= 0, t < count else { return nil }
        return Array(self[f...t])
    }
    
    func fill(num: Int?, i: Element, append: Bool = true) -> [Element] {
        guard let c = num, c > 0, c > count else { return self }
        var newArr = Array(self)
        let difArr = Array(repeating: i, count: c - count)
        if append {
            newArr.append(contentsOf: difArr)
        } else {
            newArr.insert(contentsOf: difArr, at: 0)
        }
        return newArr
    }
    
    /// 二分查找
    func binarySearch<T: Comparable>(_ s: (Element) -> T, key: T) -> (idx: Int?, element: Element?) {
        var lowerBound = 0
        var upperBound = count
        while lowerBound < upperBound {
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            let currentElementValue = s(self[midIndex])
            switch (currentElementValue == key, currentElementValue < key) {
            case (true, _): return (midIndex, self[midIndex])
            case (_, true): lowerBound = midIndex + 1
            default: upperBound = midIndex
            }
        }
        return (nil, nil)
    }
    
    mutating func replace(idx: Int, element: Element) {
        remove(at: idx)
        insert(element, at: idx)
    }
}

extension Array where Element: Equatable {
    mutating func appendUnique(_ element: Element) {
        if index(of: element) == nil {
            append(element)
        }
    }
    
    mutating func insertUnique(_ element: Element, at: Int) {
        if index(of: element) == nil {
            insert(element, at: at)
        }
    }
    
    mutating func existThenRemove(_ element: Element) {
        if let idx = index(of: element) {
            remove(at: idx)
        }
    }
}
