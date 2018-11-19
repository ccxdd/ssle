//
//  SCR.swift
//  Finger
//
//  Created by ccxdd on 2016/10/19.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit

public struct SCR {
    static let H = UIScreen.main.bounds.height
    static let W = UIScreen.main.bounds.width
    static let B = UIScreen.main.bounds
    static var navigationBarHeight: CGFloat {
        return iPhoneX ? 88 : 64
    }
    static var tabBarHeight: CGFloat {
        return iPhoneX ? 83 : 49
    }
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    static let iPhoneX: Bool = H == 812
    
    static func H(_ multiplier: CGFloat?) -> CGFloat {
        guard let d = multiplier else { return 0 }
        return SCR.H * d
    }
    
    static func W(_ multiplier: CGFloat?) -> CGFloat {
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
