//
//  UIView+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/10/20.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

enum MoveDirection {
    case none, up, left, down, right
}

enum BorderStyle {
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

extension UIView {
    
    private var additional: UIViewAdditional {
        guard let bdm = objc_getAssociatedObject(self, &BorderManagerKey) as? UIViewAdditional else {
            let bdm = UIViewAdditional()
            objc_setAssociatedObject(self, &BorderManagerKey, bdm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bdm
        }
        return bdm
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
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
    
    func corner(radius: CGFloat, color: UIColor? = nil, width: CGFloat = 0) {
        layer.cornerRadius = radius
        layer.borderWidth = width
        layer.borderColor = color?.cgColor
    }
    
    func addBorder(style: BorderStyle, w: CGFloat = 0.5, t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0, c: UIColor? = nil) {
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
    
    @IBInspectable var tw: CGFloat {
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
    
    @IBInspectable var tt: CGFloat {
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
    
    @IBInspectable var tl: CGFloat {
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
    
    @IBInspectable var tr: CGFloat {
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
    
    @IBInspectable var tc: UIColor? {
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
    
    @IBInspectable var lw: CGFloat {
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
    
    @IBInspectable var lt: CGFloat {
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
    
    @IBInspectable var ll: CGFloat {
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
    
    @IBInspectable var lb: CGFloat {
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
    
    @IBInspectable var lc: UIColor? {
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
    
    @IBInspectable var bw: CGFloat {
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
    
    @IBInspectable var bl: CGFloat {
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
    
    @IBInspectable var bb: CGFloat {
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
    
    @IBInspectable var br: CGFloat {
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
    
    @IBInspectable var bc: UIColor? {
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
    
    @IBInspectable var rw: CGFloat {
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
    
    @IBInspectable var rt: CGFloat {
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
    
    @IBInspectable var rb: CGFloat {
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
    
    @IBInspectable var rr: CGFloat {
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
    
    @IBInspectable var rc: UIColor? {
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
    
    @IBInspectable var tapDismiss: Bool {
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
    
    @IBInspectable var tapEndEditing: Bool {
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
    
    func addTap(taps: Int = 1, touchs: Int = 1, closure: @escaping (UITapGestureRecognizer?) -> Void) {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(gestureTap(_:)))
        tapGes.numberOfTapsRequired = taps
        tapGes.numberOfTouchesRequired = touchs
        addGestureRecognizer(tapGes)
        cbm.tap(t: UITapGestureRecognizer.self, c: closure)
    }
    
    func exeTap() {
        cbm.exec(c: .tapGes, p: true)
    }
    
    @objc private func gestureTap(_ sender: UITapGestureRecognizer) {
        cbm.exec(c: .tapGes, p: sender)
    }
    
    func addAutoLayout(view: UIView) {
        addSubview(view)
        view.lcm.lead().t().b().trail()
    }
    
    func insertAutoLayout(view: UIView, at: Int) {
        insertSubview(view, at: at)
        view.lcm.lead().t().b().trail()
    }
    
    static func xib<T: UIView>(_ t: T.Type, w: CGFloat = 0, h: CGFloat = 0) -> T? {
        if let view = Bundle.main.loadNibNamed(t.toStr, owner: nil, options: nil)?.first as? T {
            let h = h > 0 ? h : view.frame.height
            let w = w > 0 ? w : view.frame.width
            view.frame.size = CGSize(width: w, height: h)
            return view
        }
        return nil
    }
    
    func shadow(color: UIColor = UIColor.black, radius: CGFloat = 3, opacity: Float = 0.5, offset: CGSize = CGSize.zero) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
    
    @discardableResult
    func addTo(view: UIView?) -> Self {
        view?.addSubview(self)
        return self
    }
    
    func moveDirection(_ pointArr: [CGPoint]) -> MoveDirection {
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
}

extension NSTextAttachment {
    var attrStr: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: NSAttributedString(attachment: self))
    }
}

extension UIImage {
    
    public enum ScaleType {
        case wh(CGFloat, CGFloat)
        case w(CGFloat)
        case h(CGFloat)
        case p(CGFloat) // 0 - 1 percent
    }
    
    var textAttachment: NSTextAttachment {
        let attachment = NSTextAttachment()
        attachment.image = self
        return attachment
    }
    
    var attrStr: NSMutableAttributedString {
        return textAttachment.attrStr
    }
    
    func scale(_ scaleType: ScaleType?) -> UIImage {
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
            UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), true, UIScreen.main.scale)
            self.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
            newImg = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
        }
        return newImg
    }
}

extension UIBezierPath {
    func toShapeLayer(fillColor: UIColor? = nil, strokeColor: UIColor? = nil, lineWidth: CGFloat? = nil) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = cgPath
        layer.fillColor = fillColor?.cgColor
        layer.strokeColor = strokeColor?.cgColor
        layer.lineWidth = lineWidth ?? 1.0
        return layer
    }
    
    var toLayer: CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = cgPath
        return layer
    }
}

extension CAShapeLayer {
    
    func addTo(layer: CALayer?) -> Self {
        guard let l = layer else { return self }
        l.addSublayer(self)
        return self
    }
    
    @discardableResult
    func fill(c: UIColor?) -> Self {
        fillColor = c?.cgColor
        return self
    }
    
    @discardableResult
    func stroke(c: UIColor?) -> Self {
        strokeColor = c?.cgColor
        return self
    }
    
    @discardableResult
    func start(v: CGFloat) -> Self {
        strokeStart = v
        return self
    }
    
    @discardableResult
    func end(v: CGFloat) -> Self {
        strokeEnd = v
        return self
    }
    
    @discardableResult
    func line(w: CGFloat) -> Self {
        lineWidth = w
        return self
    }
    
    @discardableResult
    func bg(c: UIColor?) -> Self {
        backgroundColor = c?.cgColor
        return self
    }
}

extension UIBezierPath {
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

extension UITextView {
    func allRange(attributed: Bool = false) -> NSRange {
        if attributed {
            return NSRange(location: 0, length: self.attributedText.length)
        } else {
            return NSRange(location: 0, length: self.text.count)
        }
    }
}

extension UILabel {
    func tapAttributed(text: String, completion: @escaping () -> Void) {
        isUserInteractionEnabled = true
        addTap { [weak self] (ges) in
            guard let s = self?.attributedText?.string else { return }
            ges?.didTapAttributedTextIn(label: self!, inRange: (s as NSString).range(of: text), completion: completion)
        }
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextIn(label: UILabel, inRange targetRange: NSRange, completion: () -> Void) {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
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
        
        if NSLocationInRange(indexOfCharacter, targetRange) {
            completion()
        }
    }
}
