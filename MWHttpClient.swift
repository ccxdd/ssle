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
    fileprivate var requestProtocol: MWRequestProtocol.Type!
    var detail = MWDetail()
    var dataRequest: DataRequest?
    #if os(iOS)
    private weak var scrollView: UIScrollView?
    private weak var control: UIControl?
    #endif
    private var hintTimer: GCDTimer?
    #if DEBUG
    private var showLog: Bool = true
    #else
    private var showLog: Bool = false
    #endif
    private var encoding: ParameterEncoding = URLEncoding.default
    private var errorResponseClosure: GenericsClosure<ResponseError>?
    private var progressClosure: GenericsClosure<Double>?
    private var logArr: [String] = []
    
    private static var customizedErrorClosure: GenericsClosure<ResponseError>?
    
    public static func customizdErrors(_ closure: GenericsClosure<ResponseError>?) {
        customizedErrorClosure = closure
    }
    
    //MARK: request MWRequestProtocol
    public static func request(_ reqProtocol: MWRequestProtocol.Type, _ resParams: Codable? = nil,
                               encoding: MWEncoding = .url) -> MWHttpClient {
        let client = MWHttpClient()
        client.requestProtocol = reqProtocol
        client.detail.name = "\(reqProtocol.self)"
        client.detail.url = reqProtocol.APIURL
        client.detail.method = reqProtocol.method
        client.detail.res = resParams
        client.encoding = encoding == .url ? URLEncoding.default : JSONEncoding.default
        client.logArr.append("🚚 \(reqProtocol.self) \(reqProtocol.APIURL) 🚚")
        return client
    }
    
    //MARK: request url:method:params:encoding:
    public static func request(_ url: String, method: HTTPMethod, params: Codable? = nil,
                               encoding: MWEncoding = .url) -> MWHttpClient {
        struct DefaultProtocol: MWRequestProtocol {
            static var APIURL = ""
            static var method = HTTPMethod.get
        }
        let client = MWHttpClient()
        client.requestProtocol = DefaultProtocol.self
        client.requestProtocol.APIURL = url
        client.requestProtocol.method = method
        client.detail.name = "RAW REQUEST"
        client.detail.url = url
        client.detail.method = method
        client.detail.res = params
        client.encoding = encoding == .url ? URLEncoding.default : JSONEncoding.default
        client.logArr.append("🚚 \(url) \(method) 🚚")
        return client
    }
    
    //MARK: responseTarget
    @discardableResult
    public func responseTarget<T>(_ target: T.Type, completion: GenericsClosure<T>? = nil) -> DataRequest? where T: Codable {
        guard detail.url.count > 0, !cacheValidCheck(T.self, completion: completion) else {
            endResponse()
            return nil
        }
        var encodedURLRequest: URLRequest!
        do {
            if encoding is URLEncoding {
                let parameters: [String: String] = Mirror.tSS(detail.res) ?? [:]
                logArr.append("params =  \(parameters)")
                encodedURLRequest = try URLEncoding.default.encode(requestProtocol.urlRequest(), with: parameters)
            } else {
                encodedURLRequest = try requestProtocol.urlRequest()
                if encodedURLRequest.value(forHTTPHeaderField: "Content-Type") != "application/json" {
                    encodedURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                encodedURLRequest.httpBody = detail.res?.tJSONString()?.data(using: .utf8)
            }
        } catch {
            logArr.append("\(error.localizedDescription)")
            return nil
        }
        encodedURLRequest.timeoutInterval = detail.timeout
        let request = Alamofire.request(encodedURLRequest).responseString { r in
            self.commonResponseHandle(r, target: target, completion: completion)
        }
        dataRequest = request
        return request
    }
    
    //MARK: responseRaw
    @discardableResult
    public func responseRaw(completion: GenericsClosure<String>? = nil) -> DataRequest? {
        return responseTarget(String.self, completion: completion)
    }
    
    //MARK: cacheValidCheck
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
    
    //MARK: commonResponseHandle
    fileprivate func commonResponseHandle<T>(_ r: DataResponse<String>, target: T.Type, completion: GenericsClosure<T>? = nil) where T: Codable {
        endResponse()
        detail.resp = r.value
        if r.result.isSuccess, let respStr = r.value {
            if respStr is T { // Raw
                successReturn(resp: respStr as! T, completion: completion)
            } else if let model = respStr.tModel(T.self) {
                switch model {
                case is MWResponseProtocol:
                    let mwResp = (model as! MWResponseProtocol)
                    if mwResp.mwSuccess {
                        successReturn(resp: model, completion: completion)
                    } else {
                        errorsReturn(err: .errorMsg(mwResp.mwCode, mwResp.mwMsg))
                    }
                default:
                    successReturn(resp: model, completion: completion)
                }
            } else {
                errorsReturn(err: .decodeModel(respStr))
            }
        } else { // failure
            errorsReturn(err: .native(r))
        }
    }
    
    //MARK: successReturn
    fileprivate func successReturn<T: Codable>(resp: T, completion: GenericsClosure<T>? = nil, useCache: Bool = false) {
        if !useCache {
            saveCache(item: resp)
        } else {
            logArr.append("♻️ Use Cache ♻️")
        }
        detail.resp = resp
        detail.useCache = useCache
        completion?(resp)
        if showLog {
            logArr.append("📌 \(detail.name), \(requestProtocol.APIURL) 📌")
            logArr.append(resp.tJSONString(prettyPrinted: true) ?? "")
            print(logArr.joined(separator: "\n"))
        }
    }
    
    //MARK: errorsReturn
    fileprivate func errorsReturn(err: ResponseError) {
        if detail.messageHint == .always {
            MWHttpClient.customizedErrorClosure?(err)
        }
        errorResponseClosure?(err)
        logArr.append("❌, \(err.jsonString ?? ""), ❌")
    }
    
    //MARK: clearCache
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
    
    //MARK: endResponse
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
    
    //MARK: saveCache
    fileprivate func saveCache<T>(item: T) where T: Codable {
        guard detail.cacheSeconds > 0 else { return }
        var saveItem = APICacheStruct<T>()
        saveItem.data = item
        if let data = saveItem.tJSONString()?.data(using: .utf8)?.encrypt(ChaCha20Key: ChaCha20Key) {
            _ = data.save(paths: folderName, detail.cacheFileName)
        }
    }
    
    //MARK: error
    @discardableResult
    public func error(_ completion: GenericsClosure<ResponseError>? = nil) -> Self {
        errorResponseClosure = completion
        return self
    }
    
    //MARK: cancel
    public func cancel() {
        dataRequest?.cancel()
    }
    
    //MARK: hud
    @discardableResult
    public func hud(_ mode: HudDisplayMode) -> Self {
        detail.hudMode = mode
        return self
    }
    
    //MARK: msg
    @discardableResult
    public func msg(_ mode: MessageHintMode) -> Self {
        detail.messageHint = mode
        return self
    }
    
    //MARK: cache
    @discardableResult
    public func cache(_ sec: TimeInterval, _ policy: CachePolicy = .invalidAfterRequest) -> Self {
        guard sec > 0 else { return self }
        detail.cachePolicy = policy
        detail.cacheSeconds = sec
        return self
    }
    
    //MARK: log
    @discardableResult
    public func log(_ isShow: Bool) -> Self {
        showLog = isShow
        return self
    }
    
    #if os(iOS)
    //MARK: ctrl
    @discardableResult
    public func ctrl(_ c: UIControl?) -> Self {
        control = c
        control?.isUserInteractionEnabled = false
        return self
    }
    #endif
    
    //MARK: timeout
    @discardableResult
    public func timeout(_ t: TimeInterval) -> Self {
        detail.timeout = t
        return self
    }
    
    #if os(iOS)
    //MARK: scrollView
    @discardableResult
    public func scrollView(_ v: UIScrollView) -> Self {
        scrollView = v
        return self
    }
    #endif
    
    //MARK: progress
    @discardableResult
    public func progress(_ c: GenericsClosure<Double>?) -> Self {
        progressClosure = c
        return self
    }
}

private let folderName: String = "RequestAPICaches"
private let ChaCha20Key = "1DkIe-29YdK2asd-k29JwK3DssdI1-0Y"

fileprivate struct APICacheStruct<T>: Codable where T: Codable {
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    var data: T?
}

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
    case errorMsg(Int, String)
    case native(DataResponse<String>)
    case error(Error)
    
    var isNative: Bool {
        switch self {
        case .native: return true
        default: return false
        }
    }
    
    var jsonString: String? {
        switch self {
        case .decodeModel(let s):
            return s
        default: return nil
        }
    }
    
    var errorMsg: (code: Int, msg: String)? {
        switch self {
        case .errorMsg(let code, let msg):
            return (code, msg)
        case .error(let err):
            return (0, err.localizedDescription)
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

public struct MWDetail {
    var name: String = ""
    var res: Codable?
    var resp: Codable?
    var err: Error?
    var url: String = ""
    var method: Alamofire.HTTPMethod = .get
    var desc: String?
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
        return (url + (res?.tJSONString() ?? "")).md5()
    }
    
    init() {}
}

public protocol MWRequestProtocol {
    static var APIURL: String { get set }
    static var method: HTTPMethod { get set }
    static var host: String { get }
    static var headerFields: [String: String] { get }
}

public extension MWRequestProtocol {
    static var headerFields: [String: String] { return [:] }
    
    static var host: String { return "" }
    
    static var fullURL: String {
        return host + APIURL
    }
    
    static func urlRequest() throws -> URLRequest {
        return try URLRequest(url: fullURL, method: method, headers: headerFields)
    }
}

public protocol MWResponseProtocol: Codable {
    var mwSuccess: Bool { get }
    var mwMsg: String { get }
    var mwCode: Int { get }
}

public extension MWResponseProtocol {
    var mwSuccess: Bool { return true }
    var mwMsg: String { return "" }
    var mwCode: Int { return 0 }
}

public enum MWEncoding {
    /// JSONEncoding
    case json
    /// URLEncoding
    case url
}

fileprivate extension Data {
    func encrypt(ChaCha20Key: String) -> Data? {
        let key: Array<UInt8> = ChaCha20Key.data(using: .utf8)!.bytes
        if let encrypted = try? ChaCha20(key: key, iv: Array(key[4..<16])).encrypt(bytes) {
            return Data(encrypted)
        }
        return nil
    }
    
    func decrypt(ChaCha20Key: String) -> Data? {
        let key: Array<UInt8> = ChaCha20Key.data(using: .utf8)!.bytes
        if let decrypted = try? ChaCha20(key: key, iv: Array(key[4..<16])).decrypt(bytes) {
            return Data(decrypted)
        }
        return nil
    }
}

