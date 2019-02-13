//
//  UIView+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/10/20.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

public enum MoveDirection {
    case none, up, left, down, right
}

public enum BorderStyle {
    case top, left, bottom, right
}

private final class UIViewAdditional {
    class BorderItem {
        var inset = UIEdgeInsets.zero
        var width: CGFloat = 0
        var color: UIColor?
        var border: UIView?
    }
    
    fileprivate var borders: [BorderStyle: BorderItem] = [.top: BorderItem(), .left: BorderItem(), .bottom: BorderItem(), .right: BorderItem()]
}

private var BorderManagerKey: Void?

public extension UIView {
    private var additional: UIViewAdditional {
        guard let bdm = objc_getAssociatedObject(self, &BorderManagerKey) as? UIViewAdditional else {
            let bdm = UIViewAdditional()
            objc_setAssociatedObject(self, &BorderManagerKey, bdm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bdm
        }
        return bdm
    }
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable public var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    public func addBorder(style: BorderStyle, w: CGFloat = 0.5, t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0, c: UIColor? = nil) {
        let border = UIView().addTo(view: self)
        additional.borders[style]?.border?.removeFromSuperview()
        additional.borders[style]?.border = nil
        additional.borders[style]?.border = border
        border.backgroundColor = c ?? UIColor.black.withAlphaComponent(0.06)
        switch style {
        case .top:
            border.lcm.t(t).l(l).r(r).h(w)
        case .left:
            border.lcm.t(t).l(l).b(b).w(w)
        case .bottom:
            border.lcm.l(l).b(b).r(r).h(w)
        case .right:
            border.lcm.t(t).b(b).r(r).w(w)
        }
    }
    
    @IBInspectable public var tw: CGFloat {
        get {
            return additional.borders[.top]?.border?.lcm.find(.height)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.top]?.border {
                view.lcm.h(newValue)
            } else {
                addBorder(style: .top, w: newValue)
            }
        }
    }
    
    @IBInspectable public var tt: CGFloat {
        get {
            return additional.borders[.top]?.border?.lcm.find(.top)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.top]?.border {
                view.lcm.t(newValue)
            } else {
                addBorder(style: .top, t: newValue)
            }
        }
    }
    
    @IBInspectable public var tl: CGFloat {
        get {
            return additional.borders[.top]?.border?.lcm.find(.left)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.top]?.border {
                view.lcm.l(newValue)
            } else {
                addBorder(style: .top, l: newValue)
            }
        }
    }
    
    @IBInspectable public var tr: CGFloat {
        get {
            return additional.borders[.top]?.border?.lcm.find(.right)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.top]?.border {
                view.lcm.r(newValue)
            } else {
                addBorder(style: .top, r: newValue)
            }
        }
    }
    
    @IBInspectable public var tc: UIColor? {
        get {
            return additional.borders[.top]?.border?.backgroundColor
        }
        set {
            if let view = additional.borders[.top]?.border {
                view.backgroundColor = newValue
            } else {
                addBorder(style: .top, c: newValue)
            }
        }
    }
    
    @IBInspectable public var lw: CGFloat {
        get {
            return additional.borders[.left]?.border?.lcm.find(.width)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.left]?.border {
                view.lcm.w(newValue)
            } else {
                addBorder(style: .left, w: newValue)
            }
        }
    }
    
    @IBInspectable public var lt: CGFloat {
        get {
            return additional.borders[.left]?.border?.lcm.find(.top)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.left]?.border {
                view.lcm.t(newValue)
            } else {
                addBorder(style: .left, t: newValue)
            }
        }
    }
    
    @IBInspectable public var ll: CGFloat {
        get {
            return additional.borders[.left]?.border?.lcm.find(.left)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.left]?.border {
                view.lcm.l(newValue)
            } else {
                addBorder(style: .left, l: newValue)
            }
        }
    }
    
    @IBInspectable public var lb: CGFloat {
        get {
            return additional.borders[.left]?.border?.lcm.find(.bottom)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.left]?.border {
                view.lcm.b(newValue)
            } else {
                addBorder(style: .left, b: newValue)
            }
        }
    }
    
    @IBInspectable public var lc: UIColor? {
        get {
            return additional.borders[.left]?.border?.backgroundColor
        }
        set {
            if let view = additional.borders[.left]?.border {
                view.backgroundColor = newValue
            } else {
                addBorder(style: .left, c: newValue)
            }
        }
    }
    
    @IBInspectable public var bw: CGFloat {
        get {
            return additional.borders[.bottom]?.border?.lcm.find(.height)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.bottom]?.border {
                view.lcm.h(newValue)
            } else {
                addBorder(style: .bottom, w: newValue)
            }
        }
    }
    
    @IBInspectable public var bl: CGFloat {
        get {
            return additional.borders[.bottom]?.border?.lcm.find(.left)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.bottom]?.border {
                view.lcm.l(newValue)
            } else {
                addBorder(style: .bottom, l: newValue)
            }
        }
    }
    
    @IBInspectable public var bb: CGFloat {
        get {
            return additional.borders[.bottom]?.border?.lcm.find(.bottom)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.bottom]?.border {
                view.lcm.b(newValue)
            } else {
                addBorder(style: .bottom, b: newValue)
            }
        }
    }
    
    @IBInspectable public var br: CGFloat {
        get {
            return additional.borders[.bottom]?.border?.lcm.find(.right)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.bottom]?.border {
                view.lcm.r(newValue)
            } else {
                addBorder(style: .bottom, r: newValue)
            }
        }
    }
    
    @IBInspectable public var bc: UIColor? {
        get {
            return additional.borders[.bottom]?.border?.backgroundColor
        }
        set {
            if let view = additional.borders[.bottom]?.border {
                view.backgroundColor = newValue
            } else {
                addBorder(style: .bottom, c: newValue)
            }
        }
    }
    
    @IBInspectable public var rw: CGFloat {
        get {
            return additional.borders[.right]?.border?.lcm.find(.width)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.right]?.border {
                view.lcm.w(newValue)
            } else {
                addBorder(style: .right, w: newValue)
            }
        }
    }
    
    @IBInspectable public var rt: CGFloat {
        get {
            return additional.borders[.right]?.border?.lcm.find(.top)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.right]?.border {
                view.lcm.t(newValue)
            } else {
                addBorder(style: .right, t: newValue)
            }
        }
    }
    
    @IBInspectable public var rb: CGFloat {
        get {
            return additional.borders[.right]?.border?.lcm.find(.bottom)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.right]?.border {
                view.lcm.b(newValue)
            } else {
                addBorder(style: .right, b: newValue)
            }
        }
    }
    
    @IBInspectable public var rr: CGFloat {
        get {
            return additional.borders[.right]?.border?.lcm.find(.right)?.constant ?? 0
        }
        set {
            if let view = additional.borders[.right]?.border {
                view.lcm.r(newValue)
            } else {
                addBorder(style: .right, r: newValue)
            }
        }
    }
    
    @IBInspectable public var rc: UIColor? {
        get {
            return additional.borders[.right]?.border?.backgroundColor
        }
        set {
            if let view = additional.borders[.right]?.border {
                view.backgroundColor = newValue
            } else {
                addBorder(style: .right, c: newValue)
            }
        }
    }
    
    @IBInspectable public var tapDismiss: Bool {
        get {
            return false
        }
        set {
            if newValue {
                addTap { [weak self] (ges) in
                    self?.endEditing(true)
                    UIViewController.currentVC?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBInspectable public var tapEndEditing: Bool {
        get {
            return false
        }
        set {
            if newValue {
                addTap { [weak self] (ges) in
                    self?.endEditing(true)
                }
            }
        }
    }
    
    public func addTap(taps: Int = 1, touchs: Int = 1, closure: @escaping (UITapGestureRecognizer?) -> Void) {
        assert((gestureRecognizers?.count ?? 0) == 0, "Many Gestures!")
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(gestureTap(_:)))
        tapGes.numberOfTapsRequired = taps
        tapGes.numberOfTouchesRequired = touchs
        addGestureRecognizer(tapGes)
        isUserInteractionEnabled = true
        cbm.tap(t: UITapGestureRecognizer.self, c: closure)
    }
    
    public func exeTap() {
        cbm.exec(c: .tapGes, p: gestureRecognizers?.last as? UITapGestureRecognizer)
    }
    
    @objc private func gestureTap(_ sender: UITapGestureRecognizer) {
        cbm.exec(c: .tapGes, p: sender)
    }
    
    public func addAutoLayout(view: UIView) {
        addSubview(view)
        view.lcm.lead().t().b().trail()
    }
    
    public func insertAutoLayout(view: UIView, at: Int) {
        insertSubview(view, at: at)
        view.lcm.lead().t().b().trail()
    }
    
    static public func xib<T: UIView>(_ t: T.Type, w: CGFloat = 0, h: CGFloat = 0) -> T? {
        if let view = Bundle.main.loadNibNamed(t.toStr, owner: nil, options: nil)?.first as? T {
            let h = h > 0 ? h : view.frame.height
            let w = w > 0 ? w : view.frame.width
            view.frame.size = CGSize(width: w, height: h)
            return view
        }
        return nil
    }
    
    public func shadow(color: UIColor = UIColor.black, radius: CGFloat = 3, opacity: Float = 0.5, offset: CGSize = CGSize.zero) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
    
    @discardableResult
    public func addTo(view: UIView?) -> Self {
        view?.addSubview(self)
        return self
    }
    
    @discardableResult
    public func insertTo(view: UIView?, at: Int) -> Self {
        view?.insertSubview(self, at: at)
        return self
    }
    
    @discardableResult
    public func insertTo(view: UIView?, above: UIView) -> Self {
        view?.insertSubview(self, aboveSubview: above)
        return self
    }
    
    @discardableResult
    public func insertTo(view: UIView?, below: UIView) -> Self {
        view?.insertSubview(self, belowSubview: below)
        return self
    }
    
    public func moveDirection(_ pointArr: [CGPoint]) -> MoveDirection {
        guard let l = pointArr.last, let l2 = pointArr.at(pointArr.count - 2) else { return .none }
        switch (l.x - l2.x, l.y - l2.y) {
        case let (x, y) where y < 0 && abs(x) < abs(y):
            return .up
        case let (x, y) where x < 0 && abs(y) < abs(x):
            return .left
        case let (x, y) where y > 0 && abs(y) > abs(x):
            return .down
        case let (x, y) where x > 0 && abs(x) > abs(y):
            return .right
        default:
            return .none
        }
    }
    
    public func screenshot(isContentSize: Bool = false) -> UIImage? {
        guard frame.size.height > 0 && frame.size.width > 0 else { return nil }
        if isContentSize, let scrollView = asTo(UIScrollView.self) {
            UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, UIScreen.main.scale)
            let savedContentOffset = scrollView.contentOffset
            let savedFrame = frame
            defer {
                UIGraphicsEndImageContext()
                scrollView.contentOffset = savedContentOffset
                frame = savedFrame
            }
            scrollView.contentOffset = .zero
            frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            let ctx: CGContext = UIGraphicsGetCurrentContext()!
            layer.render(in: ctx)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        } else {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    public func gradientBg(colors: [UIColor], locations: [Float], start: CGPoint, end: CGPoint, frame: CGRect? = nil) {
        let bgLayer = CAGradientLayer()
        bgLayer.frame = frame ?? bounds
        bgLayer.colors = colors.map({$0.cgColor})
        bgLayer.startPoint = start
        bgLayer.endPoint = end
        bgLayer.locations = locations as [NSNumber]
        layer.insertSublayer(bgLayer, at: 0)
    }
    
    public func gradientLayer(_ layer: CAGradientLayer) {
        self.layer.insertSublayer(layer, at: 0)
    }
}

public extension NSTextAttachment {
    public var attrStr: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: NSAttributedString(attachment: self))
    }
}

public extension UIImage {
    public enum ScaleType {
        case wh(CGFloat, CGFloat)
        case w(CGFloat)
        case h(CGFloat)
        case p(CGFloat) // 0 - 1 percent
    }
    
    public var textAttachment: NSTextAttachment {
        let attachment = NSTextAttachment()
        attachment.image = self
        return attachment
    }
    
    public var attrStr: NSMutableAttributedString {
        return textAttachment.attrStr
    }
    
    public func scale(_ scaleType: ScaleType?, tintColor: UIColor? = nil) -> UIImage {
        guard let type = scaleType else { return self }
        var newImg: UIImage = self
        let w: CGFloat
        let h: CGFloat
        switch type {
        case let .wh(a, b):
            w = a
            h = b
        case let .w(a):
            w = a
            h = a / size.width * size.height
        case let .h(a):
            h = a
            w = a / size.height * size.width
        case let .p(a):
            w = size.width * a
            h = size.height * a
        }
        if w > 0, h > 0 {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, UIScreen.main.scale)
            tintColor?.setFill()
            draw(in: CGRect(x: 0, y: 0, width: w, height: h))
            newImg = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
        }
        return newImg
    }
    
    public func saveToAlbum(_ completion: NoParamClosure? = nil) {
        cbm.empty(c: completion)
        UIImageWriteToSavedPhotosAlbum(self, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            UIAlertController.alert(title: nil, message: error.description, buttons: "OK")
        } else {
            cbm.exec(c: .empty, p: 0)
        }
    }
}

public extension CALayer {
    /// 通过mask设置
    @discardableResult
    public func setCorner(_ corners: UIRectCorner = .allCorners, radii: CGFloat, frame: CGRect? = nil) -> Self {
        let maskLayer = UIBezierPath(roundedRect: frame ?? bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
            .toShapeLayer(fillColor: .white)
        mask = maskLayer
        return self
    }
}

public extension CAShapeLayer {
    @discardableResult
    public func addTo(layer: CALayer?) -> Self {
        guard let l = layer else { return self }
        l.addSublayer(self)
        return self
    }
    
    @discardableResult
    public func fill(c: UIColor?) -> Self {
        fillColor = c?.cgColor
        return self
    }
    
    @discardableResult
    public func stroke(c: UIColor?) -> Self {
        strokeColor = c?.cgColor
        return self
    }
    
    @discardableResult
    public func start(v: CGFloat) -> Self {
        strokeStart = v
        return self
    }
    
    @discardableResult
    public func end(v: CGFloat) -> Self {
        strokeEnd = v
        return self
    }
    
    @discardableResult
    public func line(w: CGFloat) -> Self {
        lineWidth = w
        return self
    }
    
    @discardableResult
    public func bg(c: UIColor?) -> Self {
        backgroundColor = c?.cgColor
        return self
    }
}

public extension CAGradientLayer {
    @discardableResult
    public func start(x: CGFloat, y: CGFloat) -> Self {
        startPoint = CGPoint(x: x, y: y)
        return self
    }
    
    @discardableResult
    public func end(x: CGFloat, y: CGFloat) -> Self {
        endPoint = CGPoint(x: x, y: y)
        return self
    }
    
    @discardableResult
    public func point(start: CGPoint) -> Self {
        startPoint = start
        return self
    }
    
    @discardableResult
    public func point(end: CGPoint) -> Self {
        startPoint = end
        return self
    }
    
    @discardableResult
    public func locations(_ arr: Float...) -> Self {
        locations = arr as [NSNumber]
        return self
    }
    
    @discardableResult
    public func colors(_ arr: UIColor...) -> Self {
        colors = arr.map({$0.cgColor})
        return self
    }
    
    @discardableResult
    public func frame(_ rect: CGRect) -> Self {
        frame = rect
        return self
    }
    
    @discardableResult
    public func frame(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> Self {
        frame = CGRect(x: x, y: y, width: w, height: h)
        return self
    }
}

public extension UIBezierPath {
    public func toShapeLayer(fillColor: UIColor? = nil, strokeColor: UIColor? = nil, lineWidth: CGFloat? = nil) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = cgPath
        layer.fillColor = fillColor?.cgColor
        layer.strokeColor = strokeColor?.cgColor
        layer.lineWidth = lineWidth ?? 1.0
        return layer
    }
    
    public var toLayer: CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = cgPath
        return layer
    }
    
    public convenience init(arcCenter center: CGPoint, radius: CGFloat, arcRadius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        self.init(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        if clockwise {
            addLine(to: center.tArcPoint(r: radius - arcRadius, pi: endAngle))
            addArc(withCenter: center, radius: radius - arcRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
            addLine(to: center.tArcPoint(r: radius, pi: startAngle))
        } else {
            addLine(to: center.tArcPoint(r: radius - arcRadius, pi: endAngle))
            addArc(withCenter: center, radius: radius - arcRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
            addLine(to: center.tArcPoint(r: radius, pi: startAngle))
        }
    }
}

public extension UITextView {
    public func allRange(attributed: Bool = false) -> NSRange {
        if attributed {
            return NSRange(location: 0, length: self.attributedText.length)
        } else {
            return NSRange(location: 0, length: self.text.count)
        }
    }
}

public extension UILabel {
    public func tapAttributed(texts: String..., completion: @escaping (Int) -> Void) {
        isUserInteractionEnabled = true
        addTap { [weak self] (ges) in
            guard let s = self?.attributedText?.string else { return }
            var rangeArr: [NSRange] = []
            for str in texts {
                rangeArr.append((s as NSString).range(of: str))
            }
            ges?.didTapAttributedTextIn(label: self!, inRangeArray: rangeArr, completion: completion)
        }
    }
}

public extension UITapGestureRecognizer {
    public func didTapAttributedTextIn(label: UILabel, inRangeArray targetRanges: [NSRange], completion: (Int) -> Void) {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        textStorage.addAttributes([.font: label.font], range: NSMakeRange(0, label.attributedText!.length))
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = location(in: label)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInLabel, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        for (idx, range) in targetRanges.enumerated() {
            if NSLocationInRange(indexOfCharacter, range) {
                completion(idx)
            }
        }
    }
}
