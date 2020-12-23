//
//  MWHttpClient.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2019/3/24.
//  Copyright © 2019年 ccxdd. All rights reserved.
//

import SSLE
import CryptoSwift
import Alamofire

public class MWHttpClient {
    fileprivate var requestProtocol: MWRequestProtocol.Type?
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
    private var encoding: MWEncoding = .queryString
    private var errorResponseClosure: GenericsClosure<ResponseError>?
    private var progressClosure: GenericsClosure<Double>?
    private var responseHeaderClosure: GenericsClosure<[AnyHashable: Any]?>?
    private var logArr: [String] = []
    
    private static var customizedErrorClosure: GenericsClosure<ResponseError>?
    private static var mwRespErrorClosure: GenericsClosure<MWResponseProtocol>?
    private static var commonHttpHeader: (() -> [String: String])?
    
    /// 公共错误回调
    public static func customizdErrors(_ closure: GenericsClosure<ResponseError>?) {
        customizedErrorClosure = closure
    }
    
    /// MWResponseProtocol ResponseError
    public static func mwResponseErrors(_ closure: GenericsClosure<MWResponseProtocol>?) {
        mwRespErrorClosure = closure
    }
    
    /// commonHttpHeader
    public static func commonHttpHeader(header: (() -> [String: String])?) {
        commonHttpHeader = header
    }
    
    //MARK: request MWRequestProtocol
    public static func request(_ reqProtocol: MWRequestProtocol.Type, _ resParams: Codable? = nil,
                               encoding: MWEncoding = .queryString) -> MWHttpClient {
        let client = MWHttpClient()
        client.requestProtocol = reqProtocol
        client.detail.name = "\(reqProtocol.self)"
        client.detail.url = reqProtocol.apiURL
        client.detail.method = reqProtocol.method
        client.detail.res = resParams
        client.encoding = encoding
        client.logArr.append("🚚 \(reqProtocol.self) \(reqProtocol.apiURL) 🚚")
        return client
    }
    
    //MARK: request url:method:params:encoding:
    public static func request(_ url: String, method: HTTPMethod, params: Codable? = nil, headers: [String: String]? = nil, encoding: MWEncoding = .queryString) -> MWHttpClient {
        let client = MWHttpClient()
        client.detail.headers = headers
        client.detail.name = "RAW REQUEST"
        client.detail.url = url
        client.detail.method = method
        client.detail.res = params
        client.encoding = encoding
        client.logArr.append("🚚 \(url) \(method) 🚚")
        return client
    }
    
    fileprivate func encodeURLRequest() -> URLRequest? {
        var request: URLRequest
        do {
            let parameters: [String: String] = Mirror.tSS(detail.res) ?? [:]
            let pactRequest: URLRequest
            logArr.append("params =  \(parameters)")
            if let rProtocol = requestProtocol {
                pactRequest = try rProtocol.urlRequest()
            } else {
                let headers = detail.headers ?? MWHttpClient.commonHttpHeader?() ?? [:]
                pactRequest = try URLRequest(url: detail.url, method: detail.method, headers: HTTPHeaders(headers))
            }
            switch encoding {
            case .queryString:
                request = try URLEncoding.queryString.encode(pactRequest, with: parameters)
            case .httpBody:
                request = try URLEncoding.httpBody.encode(pactRequest, with: parameters)
            case .json:
                request = try JSONEncoding.default.encode(pactRequest, with: parameters)
            case .body(let data):
                request = try URLEncoding.default.encode(pactRequest, with: nil)
                request.httpBody = data
            }
        } catch {
            logArr.append("\(error.localizedDescription)")
            return nil
        }
        request.timeoutInterval = detail.timeout
        return request
    }
    
    //MARK: responseTarget
    @discardableResult
    public func responseTarget<T>(_ target: T.Type, completion: GenericsClosure<T>? = nil) -> DataRequest? where T: Codable {
        guard detail.url.count > 0, !cacheValidCheck(T.self, completion: completion) else {
            endResponse()
            return nil
        }
        guard let request = encodeURLRequest() else { return nil }
        dataRequest = AF.request(request).responseDecodable(of: target) { (dataResp) in
            self.endResponse()
            self.responseHeaderClosure?(dataResp.response?.allHeaderFields)
            if let r = dataResp.value {
                self.successReturn(resp: r, completion: completion)
            } else if let err = dataResp.error {
                self.errorsReturn(err: .AFError(err))
            }
        }
        return dataRequest
    }
    
    //MARK: responseRaw
    @discardableResult
    public func responseRaw(completion: GenericsClosure<String>? = nil) -> DataRequest? {
        guard detail.url.count > 0, !cacheValidCheck(String.self, completion: completion) else {
            endResponse()
            return nil
        }
        guard let request = encodeURLRequest() else { return nil }
        dataRequest = AF.request(request).responseString { (dataResp) in
            self.endResponse()
            self.responseHeaderClosure?(dataResp.response?.allHeaderFields)
            if let r = dataResp.value {
                self.successReturn(resp: r, completion: completion)
            } else if let err = dataResp.error {
                self.errorsReturn(err: .AFError(err))
            }
        }
        return dataRequest
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
    
    //MARK: successReturn
    fileprivate func successReturn<T: Codable>(resp: T, completion: GenericsClosure<T>? = nil, useCache: Bool = false) {
        if !useCache {
            saveCache(item: resp)
        } else {
            logArr.append("♻️ Use Cache ♻️")
        }
        detail.resp = resp
        detail.useCache = useCache
        if let mwResp = resp as? MWResponseProtocol {
            if mwResp.mwSuccess {
                completion?(resp)
            } else {
                MWHttpClient.mwRespErrorClosure?(mwResp)
            }
        } else {
            completion?(resp)
        }
        if showLog {
            logArr.append("📌 \(detail.name), \(detail.url) 📌")
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
    public func scrollView(_ v: UIScrollView?) -> Self {
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
    
    //MARK: Response Header
    @discardableResult
    public func responseHeader(_ c: GenericsClosure<[AnyHashable: Any]?>?) -> Self {
        responseHeaderClosure = c
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
    case AFError(AFError)
    case error(Error)
    
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
        case .AFError(let afErr):
            return (0, afErr.localizedDescription)
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
    var headers: [String: String]?
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
    static var apiURL: String { get set }
    static var method: HTTPMethod { get set }
    static var host: String { get }
    static var headerFields: [String: String] { get }
}

public extension MWRequestProtocol {
    static var fullURL: String {
        return host + apiURL
    }
    
    static func urlRequest() throws -> URLRequest {
        return try URLRequest(url: fullURL, method: method, headers: HTTPHeaders(headerFields))
    }
}

public protocol MWResponseProtocol: Codable {
    var mwSuccess: Bool { get }
    var mwMsg: String { get }
    var mwCode: String { get }
}

public extension MWResponseProtocol {
    var mwSuccess: Bool { return true }
    var mwMsg: String { return "" }
    var mwCode: String { return "" }
}

public enum MWEncoding {
    /// JSONEncoding
    case json
    /// URLEncoding
    case queryString
    /// URLEncoding
    case httpBody
    /// httpBody = data
    case body(Data?)
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

