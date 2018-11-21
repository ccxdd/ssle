//
//  UICollectionViewCell+extension+mw.swift
//  UICollectionView+extension+mw
//
//  Created by 陈晓东 on 2018/1/31.
//  Copyright © 2018年 ccxdd. All rights reserved.
//

import UIKit

public extension UICollectionViewCell {
    var collectionView: UICollectionView? {
        return superview as? UICollectionView
    }
    
    func selectedIndexPath(def: IndexPath? = nil) -> IndexPath? {
        return collectionView?.selectedIndexPath ?? def
    }
}
