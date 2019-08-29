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
    
    public static func request(_ resStruct: MWRequestProtocol.Type, _ resParams: Codable? = nil,
                               encoding: ParameterEncoding = URLEncoding.default) -> MWHttpClient {
        let client = MWHttpClient()
        client.apiProtocol = resStruct
        client.detail.name = "\(resStruct.self)"
        client.detail.apiCategory = resStruct.apiCategory
        client.detail.res = resParams
        client.encoding = encoding
        print("🚚", resStruct.self, resStruct.apiCategory, "🚚")
        return client
    }
    
    public static func request(_ url: String, method: HTTPMethod, params: Codable? = nil,
                               encoding: ParameterEncoding = URLEncoding.default) -> MWHttpClient {
        struct customizeReqProtocol: MWRequestProtocol {
            static var apiCategory: APICategory = .base(url: "", method: .get, desc: "")
        }
        let client = MWHttpClient()
        client.apiProtocol = customizeReqProtocol.self
        client.apiProtocol.apiCategory = .base(url: url, method: method, desc: "")
        client.detail.name = "CUSTOMIZE REQUEST"
        client.detail.apiCategory = client.apiProtocol.apiCategory
        client.detail.res = params
        client.encoding = encoding
        print("🚚", url, method, "🚚")
        return client
    }
    
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
                var urlRequest = try apiProtocol.urlRequest()
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                urlRequest.httpBody = detail.res?.tJSONString()?.data(using: .utf8)
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
    
    @discardableResult
    public func responseEmpty(completion: NoParamClosure? = nil) -> DataRequest? {
        emptyResponseClosure = completion
        return responseTarget(EmptyResponse.self)
    }
    
    @discardableResult
    public func responseRaw(completion: GenericsClosure<String>? = nil) -> DataRequest? {
        guard detail.apiCategory.params.url.count > 0, !cacheValidCheck(String.self, completion: completion) else {
            endResponse()
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
            self.commonResponseHandle(r, raw: true, target: String.self, completion: completion)
        }
        dataRequest = request
        return request
    }
    
    public static func upload(_ resStruct: MWRequestProtocol.Type, uploadRes: MWUploadRequest) -> MWHttpClient {
        let client = MWHttpClient()
        client.apiProtocol = resStruct
        client.detail.name = "\(resStruct.self)"
        client.detail.apiCategory = resStruct.apiCategory
        client.detail.res = uploadRes
        print("🚚", resStruct.self, resStruct.apiCategory, "🚚")
        return client
    }
    
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
    
    @discardableResult
    public func progress(_ c: GenericsClosure<Double>?) -> Self {
        progressClosure = c
        return self
    }
    
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
    
    fileprivate func commonResponseHandle<T>(_ r: DataResponse<String>, raw: Bool = false, target: T.Type, completion: GenericsClosure<T>? = nil) where T: Codable {
        endResponse()
        detail.resp = r.value
        if r.result.isSuccess, let respStr = r.value {
            if raw {
                completion?(respStr as! T)
                return
            }
            let comm = respStr.tModel(CommonResponse<T>.self)
            switch comm?.success {
            case true?:
                guard let data = comm?.data else {
                    emptyResponseClosure?()
                    return
                }
                self.successReturn(resp: data, completion: completion)
            case false?:
                self.errorsReturn(err: .errorMsg(comm?.code ?? 0, comm?.msg ?? ""))
            case nil:
                self.errorsReturn(err: .decodeModel(respStr))
            }
        } else { // failure
            self.errorsReturn(err: .native(r))
        }
    }
    
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
    
    fileprivate func errorsReturn(err: ResponseError) {
        if detail.messageHint == .always {
            MWHttpClient.customizedErrorClosure?(err)
        }
        errorResponseClosure?(err)
        print("❌", err, "❌")
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

fileprivate struct APICacheStruct<T>: Codable where T: Codable {
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    var data: T?
}

fileprivate struct EmptyResponse: Codable {}

fileprivate struct CommonResponse<T>: Codable where T: Codable {
    var code: Int?
    var msg: String?
    var data: T?
    var success: Bool = false
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
