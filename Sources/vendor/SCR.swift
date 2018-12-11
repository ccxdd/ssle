//
//  SCR.swift
//  Finger
//
//  Created by ccxdd on 2016/10/19.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

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
    public static var iPhoneX: Bool {
        return H >= 812
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
