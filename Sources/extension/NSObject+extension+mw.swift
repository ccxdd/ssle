//
//  NSObject+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/10/27.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

#if os(iOS)
import UIKit

public extension NSObject {
    static public var toStr: String {
        return String(describing: self)
    }
    
    public var typeOfString: String {
        return type(of: self).toStr
    }
    
    public func asTo<T: NSObject>(_ typeName: T.Type) -> T? {
        return self as? T
    }
    
    public func asNotTo<T: NSObject>(_ typeName: T.Type) -> Self? {
        if !isKind(of: typeName) {
            return self
        }
        return nil
    }
}

private var NSTextAttachmentKey: Void?

public extension NSTextAttachment {
    public var specialName: String? {
        get {
            return objc_getAssociatedObject(self, &NSTextAttachmentKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &NSTextAttachmentKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
#endif
