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
    var detail = MWDetail()
    var dataRequest: DataRequest?
    #if os(iOS)
    private weak var scrollView: UIScrollView?
    private weak var control: UIControl?
    #endif
    private var hintTimer: GCDTimer?
    private var showLog: Bool = true
    private var encoding: ParameterEncoding = URLEncoding.default
    private var emptyResponseClosure: NoParamClosure?
    private var errorResponseClosure: GenericsClosure<ResponseError>?
    private var progressClosure: GenericsClosure<Double>?
    
    private static var customizedErrorClosure: GenericsClosure<ResponseError>?
    
    public static func customizdErrors(_ closure: GenericsClosure<ResponseError>?) {
        customizedErrorClosure = closure
    }
    
    //MARK: request MWRequestProtocol
    public static func request(_ resStruct: MWRequestProtocol.Type, _ resParams: Codable? = nil,
                               encoding: MWEncoding = .url) -> MWHttpClient {
        let client = MWHttpClient()
        client.apiProtocol = resStruct
        client.detail.name = "\(resStruct.self)"
        client.detail.apiCategory = resStruct.apiCategory
        client.detail.res = resParams
        client.encoding = encoding == .url ? URLEncoding.default : JSONEncoding.default
        print("🚚", resStruct.self, resStruct.apiCategory, "🚚")
        return client
    }
    
    //MARK: request url:method:params:encoding:
    public static func request(_ url: String, method: HTTPMethod, params: Codable? = nil,
                               encoding: MWEncoding = .url) -> MWHttpClient {
        struct customizeReqProtocol: MWRequestProtocol {
            static var apiCategory: APICategory = .base(url: "", method: .get, desc: "")
        }
        let client = MWHttpClient()
        client.apiProtocol = customizeReqProtocol.self
        client.apiProtocol.apiCategory = .base(url: url, method: method, desc: "")
        client.detail.name = "CUSTOMIZE REQUEST"
        client.detail.apiCategory = client.apiProtocol.apiCategory
        client.detail.res = params
        client.encoding = encoding == .url ? URLEncoding.default : JSONEncoding.default
        print("🚚", url, method, "🚚")
        return client
    }
    
    //MARK: responseTarget
    @discardableResult
    public func responseTarget<T>(_ target: T.Type, completion: GenericsClosure<T>? = nil) -> DataRequest? where T: Codable {
        guard detail.apiCategory.params.url.count > 0, !cacheValidCheck(T.self, completion: completion) else {
            endResponse()
            return nil
        }
        guard case .base = apiProtocol.apiCategory else {
            uploadResponse(target, completion: completion)
            return nil
        }
        var encodedURLRequest: URLRequest!
        do {
            if encoding is URLEncoding {
                let parameters: [String: String] = Mirror.tSS(detail.res) ?? [:]
                print("params = ", parameters)
                encodedURLRequest = try URLEncoding.default.encode(apiProtocol.urlRequest(), with: parameters)
            } else {
                encodedURLRequest = try apiProtocol.urlRequest()
                if encodedURLRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    encodedURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                encodedURLRequest.httpBody = detail.res?.tJSONString()?.data(using: .utf8)
            }
        } catch {
            print(error)
            return nil
        }
        encodedURLRequest.timeoutInterval = detail.timeout
        let request = Alamofire.request(encodedURLRequest).responseString { r in
            self.commonResponseHandle(r, target: target, completion: completion)
        }
        dataRequest = request
        return request
    }
    
    //MARK: responseEmpty
    @discardableResult
    public func responseEmpty(completion: NoParamClosure? = nil) -> DataRequest? {
        emptyResponseClosure = completion
        return responseTarget(EmptyResponse.self)
    }
    
    //MARK: responseRaw
    @discardableResult
    public func responseRaw(completion: GenericsClosure<String>? = nil) -> DataRequest? {
        return responseTarget(String.self, completion: completion)
    }
    
    //MARK: upload
    public static func upload(_ resStruct: MWRequestProtocol.Type, uploadRes: MWUploadRequest) -> MWHttpClient {
        let client = MWHttpClient()
        client.apiProtocol = resStruct
        client.detail.name = "\(resStruct.self)"
        client.detail.apiCategory = resStruct.apiCategory
        client.detail.res = uploadRes
        print("🚚", resStruct.self, resStruct.apiCategory, "🚚")
        return client
    }
    
    //MARK: uploadResponse
    fileprivate func uploadResponse<T>(_ target: T.Type, completion: GenericsClosure<T>? = nil) where T: Codable {
        guard let res = detail.res as? MWUploadRequest else { return }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(res.img, withName: "file", fileName: "file", mimeType: "image/jpeg")
                multipartFormData.append(res.category.data(using: .utf8)!, withName: "category")
        },
            to: apiProtocol.fullURL,
            headers: apiProtocol.headerFields,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (p) in
                        self.progressClosure?(p.fractionCompleted)
                    })
                    upload.responseString { (r ) in
                        self.commonResponseHandle(r, target: target, completion: completion)
                    }
                case .failure(let encodingError):
                    self.errorsReturn(err: ResponseError.error(encodingError))
                    #if os(iOS)
                    UIAlertController.alert(message: encodingError.localizedDescription, buttons: "OK")
                    #endif
                }
        })
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
                        if mwResp.mwResponseData != nil {
                            successReturn(resp: model, completion: completion)
                        } else {
                            emptyResponseClosure?()
                        }
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
            self.errorsReturn(err: .native(r))
        }
    }
    
    //MARK: successReturn
    fileprivate func successReturn<T: Codable>(resp: T, completion: GenericsClosure<T>? = nil, useCache: Bool = false) {
        if !useCache {
            saveCache(item: resp)
        } else {
            print("♻️ Use Cache ♻️")
        }
        detail.resp = resp
        detail.useCache = useCache
        completion?(resp)
        if showLog {
            print("📌", detail.name, apiProtocol.apiCategory, "📌")
            print(resp)
        }
    }
    
    //MARK: errorsReturn
    fileprivate func errorsReturn(err: ResponseError) {
        if detail.messageHint == .always {
            MWHttpClient.customizedErrorClosure?(err)
        }
        errorResponseClosure?(err)
        print("❌", err, "❌")
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

fileprivate struct EmptyResponse: Codable {}

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
    
    public var isNative: Bool {
        switch self {
        case .native: return true
        default: return false
        }
    }
    
    public var jsonString: String? {
        switch self {
        case .decodeModel(let s):
            return s
        default: return nil
        }
    }
    
    public var errorMsg: (code: Int, msg: String)? {
        switch self {
        case .errorMsg(let code, let msg):
            return (code, msg)
        case .error(let err):
            return (0, err.localizedDescription)
        default: return nil
        }
    }
    
    public var dataResponse: DataResponse<String>? {
        switch self {
        case .native(let d):
            return d
        default: return nil
        }
    }
}

public struct MWDetail {
    public var name: String = ""
    public var res: Codable?
    public var resp: Codable?
    public var err: Error?
    public var apiCategory: APICategory = .base(url: "", method: .get, desc: "")
    public var cacheSeconds: TimeInterval = 0
    public var useCache = false
    public var startTimestamp = Date().timeIntervalSinceReferenceDate
    public var endTimestamp: TimeInterval = 0
    public var timeout: TimeInterval = 30
    public var responseTime: String {
        return (endTimestamp - startTimestamp).decimal(digits: 3).string
    }
    public var hudMode: HudDisplayMode = .always
    public var cachePolicy: CachePolicy = .invalidAfterRequest
    public var messageHint: MessageHintMode = .always
    public var cacheFileName: String {
        return (apiCategory.params.url + (res?.tJSONString() ?? "")).md5()
    }
    
    public init() {}
}

public struct MWUploadRequest: Codable {
    public var img: Data
    public var category: String
    
    public init(img: Data, category: String) {
        self.category = category
        self.img = img
    }
}

public protocol MWRequestProtocol {
    static var apiCategory: APICategory { get set }
    static var host: String { get }
    static var headerFields: [String: String] { get }
}

public extension MWRequestProtocol {
    static var headerFields: [String: String] { return [:] }
    
    static var host: String { return "" }
    
    static var fullURL: String {
        return host + apiCategory.params.url
    }
    
    static func urlRequest() throws -> URLRequest {
        return try URLRequest(url: fullURL, method: apiCategory.params.method, headers: headerFields)
    }
}

public protocol MWResponseProtocol: Codable {
    var mwSuccess: Bool { get }
    var mwMsg: String { get }
    var mwCode: Int { get }
    var mwResponseData: Codable? { get }
}

public extension MWResponseProtocol {
    var mwSuccess: Bool { return true }
    var mwMsg: String { return "" }
    var mwCode: Int { return 0 }
    var mwResponseData: Codable? { return nil }
}

public enum APICategory {
    case base(url: String, method: HTTPMethod, desc: String)
    case upload(url: String, desc: String)
    
    public var params: (url: String, method: HTTPMethod, desc: String) {
        switch self {
        case .base(url: let u, method: let m, desc: let d):
            return (u, m, d)
        case .upload(url: let u, desc: let d):
            return (u, .post, d)
        default: return ("", .get, "")
        }
    }
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

