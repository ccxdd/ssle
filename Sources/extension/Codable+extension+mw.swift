//
//  Codable+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2018/1/10.
//  Copyright © 2018年 陈晓东. All rights reserved.
//

import Foundation

public extension Encodable {
    public func tJSONString(prettyPrinted: Bool = false) -> String? {
        do {
            let encoder = JSONEncoder()
            if prettyPrinted {
                encoder.outputFormatting = .prettyPrinted
            }
            let result = try encoder.encode(self).tString
            return result
        } catch {
            print("❌", error, "❌")
            return nil
        }
    }
}

public extension Data {
    public func tModel<T>(_ model: T.Type) -> T? where T: Decodable {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(model, from: self)
            return result
        } catch {
            print("❌", error, "❌")
            return nil
        }
    }
    
    public func tJSONString() -> String? {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: self)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted)
            return jsonData.tString
        } catch {
            print("❌", error, "❌")
        }
        return nil
    }
    
    public var tString: String? {
        guard let s = String(data: self, encoding: .utf8) else { return nil }
        return s as String
    }
}
