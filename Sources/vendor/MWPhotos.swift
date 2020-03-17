//
//  MWPhotos.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/11/4.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit
import AVFoundation

public final class MWPhotos: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public enum OperationBehavior {
        case imgOpen(edit: Bool, scale: UIImage.ScaleType?)
        case imgCapture(edit: Bool, scale: UIImage.ScaleType?)
        case videoOpen
        case videoCapture(duration: TimeInterval, quality: UIImagePickerController.QualityType)
    }
    
    public enum Result {
        case img(UIImage)
        case video(URL, Data)
        
        var data: Data? {
            var result: Data?
            switch self {
            case .img(let img):
                result = img.pngData()
            case let .video(_, video):
                result = video
            }
            return result
        }
    }
    
    private var completion: ((Result) -> Void)?
    private var currentBehavior: OperationBehavior = .imgOpen(edit: false, scale: nil)
    
    private static let shared = MWPhotos()
    
    private override init () {}
    
    public static func mediaFrom(_ behaviors: OperationBehavior..., completion: @escaping GenericsClosure<MWPhotos.Result>) {
        var behaviorsDict: [Int: OperationBehavior] = [:]
        var chooseTitles: [String] = []
        let photos = MWPhotos()
        photos.completion = completion
        for beh in behaviors {
            switch beh {
            case .imgOpen(edit: _, scale: _):
                chooseTitles.appendUnique("🏞")
                behaviorsDict[0] = beh
            case .imgCapture(edit: _, scale: _):
                chooseTitles.appendUnique("📷")
                behaviorsDict[1] = beh
            case .videoOpen:
                chooseTitles.appendUnique("🎞")
                behaviorsDict[2] = beh
            case .videoCapture(duration: _):
                chooseTitles.appendUnique("📹")
                behaviorsDict[3] = beh
            }
        }
        UIAlertController.sheet(title: nil, buttons: chooseTitles) { idx in
            self.chooseBeh(behaviorsDict[idx]!, completion: completion)
        }
    }
    
    public static func chooseBeh(_ beh: OperationBehavior, completion: @escaping GenericsClosure<MWPhotos.Result>) {
        let vc = UIImagePickerController()
        vc.delegate = shared
        shared.currentBehavior = beh
        shared.completion = completion
        switch beh {
        case .imgOpen(edit: let e, scale: _):
            APP.auth(type: .photos) {
                vc.allowsEditing = e
                vc.sourceType = .photoLibrary
            }
        case .imgCapture(edit: let e, scale: _):
            APP.auth(type: .camera) {
                vc.allowsEditing = e
                vc.sourceType = .camera
            }
        case .videoOpen:
            vc.sourceType = .photoLibrary
            vc.mediaTypes = ["public.movie"]
        case .videoCapture(duration: let i, quality: let q):
            APP.auth(type: .camera) {
                vc.sourceType = .camera
                vc.mediaTypes = ["public.movie"]
                vc.videoQuality = q
                vc.videoMaximumDuration = i
            }
        }
        UIViewController.currentVC?.present(vc: vc)
    }
    
    // MARK: - UIImagePickerControllerDelegate -
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        switch currentBehavior {
        case .imgOpen(edit: _, scale: let s), .imgCapture(edit: _, scale: let s):
            guard let img = (picker.allowsEditing ? info[UIImagePickerController.InfoKey.editedImage] : info[UIImagePickerController.InfoKey.originalImage]) as? UIImage else { return }
            picker.dismiss(animated: true) { [weak self] in
                self?.completion?(.img(img.scale(s)))
            }
        case .videoOpen, .videoCapture(duration: _):
            guard let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            picker.dismiss(animated: true) { [weak self] in
                print(url)
                let data = try? Data(contentsOf: url)
                self?.completion?(.video(url, data!))
            }
        }
    }
}

public extension UIAlertController {
    class func photoChose(edit: Bool = false, scale: UIImage.ScaleType? = nil, closure: @escaping (UIImage) -> Void) {
        MWPhotos.mediaFrom(.imgOpen(edit: edit, scale: scale), .imgCapture(edit: edit, scale: scale)) { (result) in
            guard case let .img(img) = result else { return }
            closure(img)
        }
    }
}
