//
//  MWHttpClient.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2019/3/24.
//  Copyright © 2019年 ccxdd. All rights reserved.
//

import CryptoSwift
import Alamofire

public class MWHttpClient {
    fileprivate var apiProtocol: MWRequestProtocol.Type!
    var detail = APIDetail()
    var dataRequest: DataRequest?
    #if os(iOS)
    private weak var scrollView: UIScrollView?
    private weak var control: UIControl?
    #endif
    private var hintTimer: GCDTimer?
    private var showLog: Bool = true
    private var emptyResponseClosure: NoParamClosure?
    private var errorResponseClosure: GenericsClosure<ResponseError>?
    
    private static var customizedResponseClosure: GenericesReturnClosure<String, Codable>?
    private static var customizedErrorClosure: GenericsClosure<ResponseError>?
    
    public static func customizdResponse(closure: GenericesReturnClosure<String, Codable>?) {
        customizedResponseClosure = closure
    }
    
    public static func customizdErrors(_ closure: GenericsClosure<ResponseError>?) {
        customizedErrorClosure = closure
    }
    
    public static func request(_ resStruct: MWRequestProtocol.Type, _ resParams: Codable? = nil) -> MWHttpClient {
        let client = MWHttpClient()
        client.apiProtocol = resStruct
        client.detail.name = "\(resStruct.self)"
        client.detail.apiInfo = resStruct.apiInfo
        client.detail.res = resParams
        print("🚧".repetitions(20))
        print(resStruct.self, resStruct.apiInfo)
        print("🚧".repetitions(20))
        return client
    }
    
    @discardableResult
    public func responseSource<S, T>(_ source: S.Type, target: T.Type, completion: GenericsClosure<T>? = nil) -> DataRequest? where T: Codable, S: Codable {
        guard detail.apiInfo.params.url.count > 0, !cacheValidCheck(T.self, completion: completion) else {
            endResponse()
            return nil
        }
        let parameters: [String: String] = Mirror.tSS(detail.res) ?? [:]
        print("resquest = ", parameters)
        // request
        var encodedURLRequest: URLRequest!
        do {
            encodedURLRequest = try URLEncoding().encode(apiProtocol.urlRequest(), with: parameters)
            encodedURLRequest.timeoutInterval = detail.timeout
        } catch {
            print(error)
            return nil
        }
        let request = Alamofire.request(encodedURLRequest).responseString { r in
            self.endResponse()
            self.detail.resp = r.result.value
            if r.result.isSuccess, let jsonStr = r.result.value {
                if type(of: jsonStr) == T.self {
                    self.successReturn(resp: jsonStr as! T, completion: completion)
                    return
                }
                // Customized
                let result: Codable
                switch (MWHttpClient.customizedResponseClosure != nil) {
                case true:
                    result = MWHttpClient.customizedResponseClosure!(jsonStr)
                case false:
                    guard let resp = jsonStr.tModel(S.self) else {
                        print("❌ 解析未成功", self.detail.name, self.apiProtocol.apiInfo, jsonStr, "❌")
                        self.errorsReturn(err: .decodeModel(jsonStr))
                        return
                    }
                    result = resp
                }
                //
                switch (source == target) {
                case true:
                    guard let r = result as? T else {
                        print("❌", "\(ResponseError.asTarget)", "❌")
                        self.errorsReturn(err: .asTarget(jsonStr))
                        return
                    }
                    self.successReturn(resp: r, completion: completion)
                case false:
                    // transform
                    guard let t = (result as? MWResponseProtocol)?.transform() else { return }
                    guard let r = t as? T else {
                        print("❌", "\(ResponseError.transform) \(type(of: t)) Error!", "❌")
                        self.errorsReturn(err: .transform(jsonStr))
                        return
                    }
                    self.successReturn(resp: r, completion: completion)
                }
            } else { // failure
                self.errorsReturn(err: .native(r))
            }
        }
        dataRequest = request
        return request
    }
    
    @discardableResult
    public func response<T>(target: T.Type, completion: GenericsClosure<T>? = nil) -> DataRequest? where T: Codable {
        return responseSource(target, target: target, completion: completion)
    }
    
    @discardableResult
    public func response(completion: NoParamClosure? = nil) -> DataRequest? {
        emptyResponseClosure = completion
        return response(target: EmptyResponse.self)
    }
    
    @discardableResult
    public func error(_ completion: GenericsClosure<ResponseError>? = nil) -> Self {
        errorResponseClosure = completion
        return self
    }
    
    public func cancel() {
        dataRequest?.cancel()
    }
    
    @discardableResult
    public func hud(_ mode: HudDisplayMode) -> Self {
        detail.hudMode = mode
        return self
    }
    
    @discardableResult
    public func msg(_ mode: MessageHintMode) -> Self {
        detail.messageHint = mode
        return self
    }
    
    @discardableResult
    public func cache(_ sec: TimeInterval, _ policy: CachePolicy = .invalidAfterRequest) -> Self {
        guard sec > 0 else { return self }
        detail.cachePolicy = policy
        detail.cacheSeconds = sec
        return self
    }
    
    @discardableResult
    public func log(_ isShow: Bool) -> Self {
        showLog = isShow
        return self
    }
    
    #if os(iOS)
    @discardableResult
    public func ctrl(_ c: UIControl?) -> Self {
        control = c
        control?.isUserInteractionEnabled = false
        return self
    }
    #endif
    
    @discardableResult
    public func timeout(_ t: TimeInterval) -> Self {
        detail.timeout = t
        return self
    }
    
    #if os(iOS)
    @discardableResult
    public func scrollView(_ v: UIScrollView) -> Self {
        scrollView = v
        return self
    }
    #endif
    
    fileprivate func endResponse() {
        detail.endTimestamp = Date().timeIntervalSinceReferenceDate
        hintTimer?.stop()
        #if os(iOS)
        if scrollView?.headerRefreshCtrl?.isRefreshing == true {
            scrollView?.endHeaderRefresh()
        }
        if scrollView?.footerRefreshCtrl?.isRefreshing == true {
            scrollView?.endFooterRefresh()
        }
        control?.isUserInteractionEnabled = true
        #endif
    }
    
    fileprivate func saveCache<T>(item: T) where T: Codable {
        guard detail.cacheSeconds > 0 else { return }
        var saveItem = APICacheStruct<T>()
        saveItem.data = item
        if let data = saveItem.tJSONString()?.data(using: .utf8)?.encrypt(ChaCha20Key: ChaCha20Key) {
            _ = data.save(paths: folderName, detail.cacheFileName)
        }
    }
    
    fileprivate func cacheValidCheck<T>(_ respModel: T.Type, completion: GenericsClosure<T>? = nil) -> Bool where T: Codable {
        guard detail.cacheSeconds > 0 else { return false }
        if let loadItem = Data.load(paths: folderName, detail.cacheFileName)?.decrypt(ChaCha20Key: ChaCha20Key)?.tModel(APICacheStruct<T>.self) {
            let isValid = (Date().timeIntervalSince1970 - loadItem.timestamp) < detail.cacheSeconds
            switch detail.cachePolicy {
            case .invalidAfterRequest:
                successReturn(resp: loadItem.data!, completion: completion, useCache: true)
                return isValid
            case .afterReturn where isValid, .afterRequest where isValid:
                successReturn(resp: loadItem.data!, completion: completion, useCache: true)
                return detail.cachePolicy == .afterReturn
            case .afterCache: break
            default: break
            }
        }
        return false
    }
    
    fileprivate func successReturn<T: Codable>(resp: T, completion: GenericsClosure<T>? = nil, useCache: Bool = false) {
        if !useCache {
            saveCache(item: resp)
        } else {
            print("♻️ Use Cache ♻️")
        }
        detail.resp = resp
        detail.useCache = useCache
        if emptyResponseClosure != nil {
            emptyResponseClosure?()
        } else {
            completion?(resp)
        }
    }
    
    fileprivate func errorsReturn(err: ResponseError) {
        MWHttpClient.customizedErrorClosure?(err)
        errorResponseClosure?(err)
    }
    
    @discardableResult
    public func clearCache() -> Self {
        var dirUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        dirUrl.appendPathComponent(folderName)
        dirUrl.appendPathComponent(detail.cacheFileName)
        if FileManager.default.fileExists(atPath: dirUrl.path) {
            try? FileManager.default.removeItem(at: dirUrl)
        }
        return self
    }
}

private let folderName: String = "RequestAPICaches"
private let ChaCha20Key = "1DkIe-29YdK2asd-k29JwK3DssdI1-0Y"

public extension MWHttpClient {
    public struct APICacheStruct<T: Codable>: Codable {
        var timestamp: TimeInterval = Date().timeIntervalSince1970
        var data: T?
    }
    
    public struct EmptyResponse: Codable {}
    
    public enum HudDisplayMode {
        case none, always
    }
    
    public enum CachePolicy {
        //有效期<=0 -> 直接请求数据，不进行缓存
        //下面不在前置条件内的都会重新请求数据并缓存使用
        //缓存存在&在有效期内 -> 仅使用缓存，不进行请求
        case afterReturn
        //缓存存在&在有效期内 -> 先使用缓存，再请求刷新缓存使用
        case afterRequest
        //缓存存在 -> 先使用缓存，再根据缓存是有效进行请求刷新缓存使用
        case invalidAfterRequest
        //缓存存在 -> 不使用缓存，刷新缓存使用
        case afterCache
    }
    
    public enum MessageHintMode {
        case none, always, callbackFirst
    }
    
    public enum ResponseError {
        case decodeModel(String)
        case asTarget(String)
        case transform(String)
        case native(DataResponse<String>)
        
        var isNative: Bool {
            switch self {
            case .native: return true
            default: return false
            }
        }
        
        var jsonString: String? {
            switch self {
            case .decodeModel(let s), .asTarget(let s), .transform(let s):
                return s
            default: return nil
            }
        }
        
        var dataResponse: DataResponse<String>? {
            switch self {
            case .native(let d):
                return d
            default: return nil
            }
        }
    }
    
    public struct APIDetail {
        var name: String = ""
        var res: Codable?
        var resp: Codable?
        var err: Error?
        var apiInfo: APIInfo = .base(url: "", method: .get, desc: "")
        var cacheSeconds: TimeInterval = 0
        var useCache = false
        var startTimestamp = Date().timeIntervalSinceReferenceDate
        var endTimestamp: TimeInterval = 0
        var timeout: TimeInterval = 30
        var responseTime: String {
            return (endTimestamp - startTimestamp).decimal(digits: 3).string
        }
        var hudMode: HudDisplayMode = .always
        var cachePolicy: CachePolicy = .invalidAfterRequest
        var messageHint: MessageHintMode = .always
        
        var cacheFileName: String {
            return (apiInfo.params.url + (res?.tJSONString() ?? "")).md5()
        }
    }
}

public protocol MWRequestProtocol {
    static var apiInfo: APIInfo { get }
    static var host: String { get }
    static var headerFields: [String: String] { get }
}

public extension MWRequestProtocol {
    static var headerFields: [String: String] { return [:] }
    
    static var host: String { return "" }
    
    static var fullURL: String {
        return host + apiInfo.params.url
    }
    
    static func urlRequest() throws -> URLRequest {
        return try URLRequest(url: fullURL, method: apiInfo.params.method, headers: headerFields)
    }
}

public protocol MWResponseProtocol: Codable {
    func transform() -> Codable
}

public enum APIInfo {
    case base(url: String, method: HTTPMethod, desc: String)
    
    var params: (url: String, method: HTTPMethod, desc: String) {
        guard case .base(let u, let m, let d) = self else { return ("", .get, "") }
        return (u, m, d)
    }
}

public extension Data {
    func encrypt(ChaCha20Key: String) -> Data? {
        let key: Array<UInt8> = ChaCha20Key.data(using: .utf8)!.bytes
        if let encrypted = try? ChaCha20(key: key, iv: Array(key[4..<16])).encrypt(bytes) {
            return Data(bytes: encrypted)
        }
        return nil
    }
    
    func decrypt(ChaCha20Key: String) -> Data? {
        let key: Array<UInt8> = ChaCha20Key.data(using: .utf8)!.bytes
        if let decrypted = try? ChaCha20(key: key, iv: Array(key[4..<16])).decrypt(bytes) {
            return Data(bytes: decrypted)
        }
        return nil
    }
}
