//
//  SCR.swift
//  Finger
//
//  Created by ccxdd on 2016/10/19.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

#if os(iOS)
import UIKit

public struct SCR {
    public static let H = UIScreen.main.bounds.height
    public static let W = UIScreen.main.bounds.width
    public static let B = UIScreen.main.bounds
    
    public static var navigationBarHeight: CGFloat {
        return iPhoneX ? 88 : 64
    }
    
    public static var tabBarHeight: CGFloat {
        return iPhoneX ? 83 : 49
    }
    
    public static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    public static var iPhoneXSeries: Bool {
        return H >= 812
    }
    
    /// 5.8 Inch 1125 x 2436
    public static var iPhoneX: Bool {
        return H == 812
    }
    
    /// 5.8 Inch 1125 x 2436
    public static var iPhoneXS: Bool {
        return iPhoneX
    }
    
    /// 6.5 Inch 1242 x 2688
    public static var iPhoneXR: Bool {
        return H == 896
    }
    
    /// 6.5 Inch 1242 x 2688
    public static var iPhoneXSMax: Bool {
        return iPhoneXR
    }
    
    /// 5.5 Inch 1242 x 2208
    public static var iPhonePlus: Bool {
        return H == 736
    }
    
    /// 4.7 Inch 750 x 1334
    public static var iPhone47: Bool {
        return H == 667
    }
    
    public static func H(_ multiplier: CGFloat?) -> CGFloat {
        guard let d = multiplier else { return 0 }
        return SCR.H * d
    }
    
    public static func W(_ multiplier: CGFloat?) -> CGFloat {
        guard let d = multiplier else { return 0 }
        return SCR.W * d
    }
}

extension CGFloat {
    public func one(_ denominator: CGFloat?) -> CGFloat {
        guard let d = denominator, d > 0 else { return self }
        return self / d;
    }
}
#endif
