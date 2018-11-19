//
//  Mirror+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/8/9.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import UIKit

extension Mirror {
    /// to Key: String, Value: Any
    static func tSA(_ obj: Any?) -> [String: Any]? {
        guard let t = obj else { return nil }
        let mirror = Mirror(reflecting: t)
        var resultDict: [String: Any] = [:]
        for i in mirror.children {
            switch i.value {
            case is String:
                resultDict[i.label!] = i.value as? String
            case is Int:
                resultDict[i.label!] = (i.value as? Int)?.tS
            case is Bool:
                resultDict[i.label!] = i.value
            case is Float:
                resultDict[i.label!] = (i.value as? Float)?.tS
            case is Double:
                resultDict[i.label!] = (i.value as? Double)?.tS
            case is UILabel:
                break
            default:
                let m = Mirror(reflecting: i.value)
                switch m.displayStyle {
                case .struct?:
                    let result = Mirror.tSA(i.value)
                    resultDict[i.label!] = result
                case .collection?:
                    resultDict[i.label!] = i.value
                case .dictionary?:
                    resultDict[i.label!] = i.value
                default: break
                }
            }
        }
        return resultDict
    }
    
    /// to Key: String, Value: String
    static func tSS(_ obj: Any?) -> [String: String]? {
        guard let t = obj else { return nil }
        let mirror = Mirror(reflecting: t)
        var resultDict: [String: String] = [:]
        for i in mirror.children {
            switch i.value {
            case is String:
                resultDict[i.label!] = i.value as? String
            case is Int:
                resultDict[i.label!] = (i.value as? Int)?.tS
            case is Bool:
                resultDict[i.label!] = (i.value as? Bool)?.description
            case is Float:
                resultDict[i.label!] = (i.value as? Float)?.tS
            case is Double:
                resultDict[i.label!] = (i.value as? Double)?.tS
            case is UILabel:
                break
            default: break
            }
        }
        return resultDict
    }
}
